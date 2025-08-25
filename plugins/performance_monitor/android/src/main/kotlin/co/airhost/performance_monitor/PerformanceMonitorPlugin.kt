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

  // Returns CPU usage (0.0..1.0)
  private fun getCpuUsage(): Double {
    return try {
      val stat1 = readProcStat()
      Thread.sleep(120)
      val stat2 = readProcStat()
      val idle1 = stat1.idle
      val idle2 = stat2.idle
      val total1 = stat1.total
      val total2 = stat2.total
      val totalDiff = max(1L, total2 - total1)
      val idleDiff = max(0L, idle2 - idle1)
      val usage = 1.0 - (idleDiff.toDouble() / totalDiff.toDouble())
      usage.coerceIn(0.0, 1.0)
    } catch (e: Exception) {
      0.0
    }
  }

  private data class CpuStat(val idle: Long, val total: Long)

  private fun readProcStat(): CpuStat {
    RandomAccessFile("/proc/stat", "r").use { reader ->
      val load = reader.readLine()
      // Format: cpu  user nice system idle iowait irq softirq steal guest guest_nice
      val toks = load.split(" ").filter { it.isNotBlank() }
      // After split, tokens like [cpu, user, nice, system, idle, iowait, irq, softirq, ...]
      val user = toks.getOrNull(1)?.toLongOrNull() ?: 0L
      val nice = toks.getOrNull(2)?.toLongOrNull() ?: 0L
      val system = toks.getOrNull(3)?.toLongOrNull() ?: 0L
      val idle = toks.getOrNull(4)?.toLongOrNull() ?: 0L
      val iowait = toks.getOrNull(5)?.toLongOrNull() ?: 0L
      val irq = toks.getOrNull(6)?.toLongOrNull() ?: 0L
      val softirq = toks.getOrNull(7)?.toLongOrNull() ?: 0L
      val steal = toks.getOrNull(8)?.toLongOrNull() ?: 0L
      val total = user + nice + system + idle + iowait + irq + softirq + steal
      return CpuStat(idle = idle + iowait, total = total)
    }
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
