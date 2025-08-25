package co.airhost.performance_monitor

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.app.ActivityManager
import android.content.Context
import java.io.RandomAccessFile
import kotlin.math.max

/** PerformanceMonitorPlugin */
class PerformanceMonitorPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var appContext: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "performance_monitor")
    channel.setMethodCallHandler(this)
    appContext = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "getCpuUsage" -> result.success(getCpuUsage())
      "getMemoryUsage" -> result.success(getMemoryUsage())
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // Returns current app's CPU usage (0.0..1.0)
  private fun getCpuUsage(): Double {
    return try {
      val pid = android.os.Process.myPid()
      val startTime = android.os.SystemClock.elapsedRealtime()
      val startCpuTime = getAppCpuTimeMs(pid)
      
      // 短暂延迟以获取有意义的差值
      Thread.sleep(200)
      
      val endTime = android.os.SystemClock.elapsedRealtime()
      val endCpuTime = getAppCpuTimeMs(pid)
      
      // 计算应用CPU使用时间占总时间的百分比
      val appTime = (endCpuTime - startCpuTime).toDouble()
      val totalTime = (endTime - startTime).toDouble()
      
      // 确保不会出现除零错误
      val usage = if (totalTime > 0) appTime / totalTime else 0.0
      
      // 范围限制在0.0-1.0之间
      usage.coerceIn(0.0, 1.0)
    } catch (e: Exception) {
      e.printStackTrace()
      0.0
    }
  }
  
  // 获取应用程序的CPU时间（毫秒）
  private fun getAppCpuTimeMs(pid: Int): Long {
    try {
      // 使用ActivityManager的方法获取进程信息，避免直接读取/proc/stat
      val am = appContext.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
      
      // 获取当前运行的进程列表
      val runningProcesses = am.runningAppProcesses ?: return estimateCpuTime()
      
      // 尝试通过进程ID找到我们的应用进程
      for (processInfo in runningProcesses) {
        if (processInfo.pid == pid) {
          // 如果找到了，尝试从进程特有的/proc/{pid}/stat读取CPU时间
          // 这个读取一般不需要特殊权限
          return readPidStat(pid)
        }
      }
      
      return estimateCpuTime()
    } catch (e: Exception) {
      e.printStackTrace()
      return estimateCpuTime()
    }
  }
  
  // 从进程特有的/proc/{pid}/stat读取CPU时间，这通常不需要特殊权限
  private fun readPidStat(pid: Int): Long {
    try {
      val path = "/proc/$pid/stat"
      try {
        val reader = java.io.RandomAccessFile(path, "r")
        val line = reader.readLine()
        reader.close()
        
        // 在stat文件中，第14和15列是utime和stime（用户和系统CPU时间）
        val parts = line.split(" ".toRegex())
        if (parts.size >= 15) {
          val utime = parts[13].toLongOrNull() ?: 0L
          val stime = parts[14].toLongOrNull() ?: 0L
          
          // 将时钟周期转换为毫秒（系统时钟频率）
          val clockTickMs = 1000L / android.os.SystemClock.currentThreadTimeMillis()
          return (utime + stime) * clockTickMs
        }
      } catch (e: java.io.IOException) {
        // 无法访问文件时返回估计值
        return estimateCpuTime()
      }
      
      return estimateCpuTime()
    } catch (e: Exception) {
      e.printStackTrace()
      return estimateCpuTime()
    }
  }
  
  // 当无法直接获取CPU时间时的估算方法
  private fun estimateCpuTime(): Long {
    val runtime = java.lang.Runtime.getRuntime()
    // 粗略估计：根据可用处理器数量和当前应用内存使用情况计算
    val processors = runtime.availableProcessors()
    val appMemory = (runtime.totalMemory() - runtime.freeMemory()) / (1024 * 1024) // MB
    
    // 使用内存和CPU核心数的简单关系估算CPU时间
    return (appMemory * processors * android.os.SystemClock.elapsedRealtime() / 1000).toLong()
  }

  // Returns memory usage percent (0.0..1.0)
  private fun getMemoryUsage(): Double {
    return try {
      val am = appContext.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
      val mi = ActivityManager.MemoryInfo()
      am.getMemoryInfo(mi)
      val total = mi.totalMem.toDouble()
      val avail = mi.availMem.toDouble()
      val usedPercent = if (total > 0) (1.0 - (avail / total)) else 0.0
      usedPercent.coerceIn(0.0, 1.0)
    } catch (e: Exception) {
      0.0
    }
  }
}
