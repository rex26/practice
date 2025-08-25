import Flutter
import UIKit
import Darwin

public class PerformanceMonitorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "performance_monitor", binaryMessenger: registrar.messenger())
    let instance = PerformanceMonitorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getCpuUsage":
      result(getCpuUsage())
    case "getMemoryUsage":
      result(getMemoryUsage())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Returns CPU usage (0.0..1.0) by sampling twice
  private func getCpuUsage() -> Double {
    do {
      let s1 = try readCpuTicks()
      usleep(120_000) // 120ms
      let s2 = try readCpuTicks()
      let total1 = s1.total
      let total2 = s2.total
      let idle1 = s1.idle
      let idle2 = s2.idle
      let totalDiff = max(1.0, Double(total2 - total1))
      let idleDiff = max(0.0, Double(idle2 - idle1))
      let usage = 1.0 - (idleDiff / totalDiff)
      return min(max(usage, 0.0), 1.0)
    } catch {
      return 0.0
    }
  }

  private struct CpuSample {
    let idle: UInt64
    let total: UInt64
  }

  private func readCpuTicks() throws -> CpuSample {
    var mib: [Int32] = [CTL_HW, HW_NCPU]
    var numCPU: UInt32 = 0
    var sizeOfNumCPU = MemoryLayout<UInt32>.size
    sysctl(&mib, 2, &numCPU, &sizeOfNumCPU, nil, 0)
    if numCPU == 0 { numCPU = 1 }

    var cpuInfo: processor_info_array_t? = nil
    var numCPUInfo: mach_msg_type_number_t = 0
    var numCPUsU: natural_t = 0
    let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCPUInfo)
    guard result == KERN_SUCCESS, let info = cpuInfo else {
      throw NSError(domain: "PerformanceMonitor", code: Int(result), userInfo: nil)
    }

    var total: UInt64 = 0
    var idle: UInt64 = 0
    let stride = Int(CPU_STATE_MAX)
    for cpu in 0..<Int(numCPUsU) {
      let base = cpu * stride
      idle += UInt64(info[base + Int(CPU_STATE_IDLE)])
      let user = UInt64(info[base + Int(CPU_STATE_USER)])
      let system = UInt64(info[base + Int(CPU_STATE_SYSTEM)])
      let nice = UInt64(info[base + Int(CPU_STATE_NICE)])
      total += user + system + nice + UInt64(info[base + Int(CPU_STATE_IDLE)])
    }
    let deallocSize = Int(numCPUInfo) * MemoryLayout<integer_t>.size
    vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info), vm_size_t(deallocSize))
    return CpuSample(idle: idle, total: total)
  }

  // Returns memory usage percent (0.0..1.0)
  private func getMemoryUsage() -> Double {
    var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)
    var hostInfo = vm_statistics64()
    var count = size
    let hostPort: mach_port_t = mach_host_self()
    let result = withUnsafeMutablePointer(to: &hostInfo) { ptr -> kern_return_t in
      ptr.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { intPtr in
        return host_statistics64(hostPort, HOST_VM_INFO64, intPtr, &count)
      }
    }
    guard result == KERN_SUCCESS else { return 0.0 }

    var pageSize: vm_size_t = 0
    host_page_size(hostPort, &pageSize)

    let total = Double(ProcessInfo.processInfo.physicalMemory)
    let freeCount = Double(hostInfo.free_count + hostInfo.inactive_count)
    let used = total - Double(freeCount) * Double(pageSize)
    if total <= 0 { return 0.0 }
    let percent = used / total
    return min(max(percent, 0.0), 1.0)
  }
}
