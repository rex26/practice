import UIKit
import Flutter
import MachO

@main
@objc class AppDelegate: FlutterAppDelegate {
  // 内存使用率缓存
  private var lastMemoryUsage: Double = 0.3
  private var lastUpdateTime: Date? = nil
  private let cacheTimeout: TimeInterval = 1.0 // 1秒内使用缓存
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 设置错误处理
    NSSetUncaughtExceptionHandler { exception in
      NSLog("[系统监控] 未捕获异常: %@", exception)
    }
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let systemStatsChannel = FlutterMethodChannel(name: "com.example.practice/system_stats",
                                               binaryMessenger: controller.binaryMessenger)
    
    systemStatsChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      
      switch call.method {
      case "getCpuUsage":
        result(self.getCPUUsage())
      case "getMemoryUsage":
        result(self.getMemoryUsage())
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // 获取CPU使用率（返回0-1范围）
  private func getCPUUsage() -> Double {
    var totalUsageOfCPU: Double = 0.0
    var threadsList: thread_act_array_t?
    var threadsCount = mach_msg_type_number_t(0)
    let threadsResult = task_threads(mach_task_self_, &threadsList, &threadsCount)
    
    // 当获取线程列表失败时的错误处理
    guard threadsResult == KERN_SUCCESS else {
      NSLog("[系统监控] 无法获取线程列表: %d", threadsResult)
      return 0.2 // 返回默认值作为回退机制
    }
    
    defer {
      // 确保正确释放线程列表资源
      if let threads = threadsList {
        let kr = vm_deallocate(mach_task_self_,
                             vm_address_t(UnsafePointer(threads).pointee),
                             vm_size_t(threadsCount * UInt32(MemoryLayout<thread_t>.size)))
        if kr != KERN_SUCCESS {
          NSLog("[系统监控] 释放线程资源失败: %d", kr)
        }
      }
    }
    
    // 计数器，用于记录有效的线程数
    var validThreads = 0
    
    for index in 0..<threadsCount {
      var threadInfo = thread_basic_info()
      var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
      let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
          thread_info(threadsList![Int(index)], thread_flavor_t(THREAD_BASIC_INFO),
                     $0, &threadInfoCount)
        }
      }
      
      if infoResult == KERN_SUCCESS {
        let threadBasicInfo = threadInfo
        if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
          totalUsageOfCPU = (totalUsageOfCPU + (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)))
          validThreads += 1
        }
      } else {
        NSLog("[系统监控] 无法获取线程信息: %d", infoResult)
      }
    }
    
    // 如果没有有效线程，返回默认值
    guard validThreads > 0 else {
      return 0.2
    }
    
    // 确保返回值在0-1范围内
    return min(max(totalUsageOfCPU, 0.0), 1.0)
  }
  
  // 获取内存使用率（返回0-1范围的值）
  private func getMemoryUsage() -> Double {
    // 如果有缓存且未超时，直接返回缓存的结果
    if let lastTime = lastUpdateTime, Date().timeIntervalSince(lastTime) < cacheTimeout {
      return lastMemoryUsage
    }
    
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
    
    let kerr = withUnsafeMutablePointer(to: &info) {
      $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        task_info(mach_task_self_,
                 task_flavor_t(MACH_TASK_BASIC_INFO),
                 $0,
                 &count)
      }
    }
    
    // 如果获取失败，返回合理的默认值
    guard kerr == KERN_SUCCESS else {
      NSLog("[系统监控] 获取内存信息失败: %d", kerr)
      return self.lastMemoryUsage // 返回上次的值以保持连续性
    }
    
    // 获取应用使用的物理内存
    let usedMemory = Double(info.resident_size)
    
    // 使用物理内存API获取总内存
    var totalMemory = Double(ProcessInfo.processInfo.physicalMemory)
    if totalMemory <= 0 {
      // 如果无法获取总内存，使用一个合理的默认值
      NSLog("[系统监控] 无法获取总内存大小")
      totalMemory = 4 * 1024 * 1024 * 1024 // 假设4GB内存
    }
    
    // 计算使用率并确保在0-1范围内
    let memoryUsage = usedMemory / totalMemory
    let normalizedUsage = min(max(memoryUsage, 0.0), 1.0)
    
    // 更新缓存
    self.lastMemoryUsage = normalizedUsage
    self.lastUpdateTime = Date()
    
    return normalizedUsage
  }
}
