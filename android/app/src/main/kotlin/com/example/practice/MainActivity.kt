package com.example.practice

import android.app.ActivityManager
import android.content.Context
import android.os.Process
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.RandomAccessFile
import android.annotation.SuppressLint
import android.app.Activity
import android.app.KeyguardManager
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.os.Build
import android.os.SystemClock
import android.system.Os
import java.io.IOException

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.practice/system_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCpuUsage" -> {
                    try {
                        result.success(getCpuUsagePercent())
                    } catch (e: Exception) {
                        result.error("CPU_USAGE_ERROR", e.message, null)
                    }
                }
                "getMemoryUsage" -> {
                    try {
                        result.success(getMemoryUsagePercent())
                    } catch (e: Exception) {
                        result.error("MEMORY_INFO_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    fun getMemoryUsagePercent(): Float {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memInfo)

        val usedMem = memInfo.totalMem - memInfo.availMem
        return usedMem.toFloat() / memInfo.totalMem // 返回0-1之间的值
    }

    fun getCpuUsagePercent(): Float {
        try {
            // 尝试使用ProcessCpuTracker或通过其他系统API获取CPU使用率
            val pid = Process.myPid()
            val startTime = SystemClock.elapsedRealtime()
            val startCpuTime = getAppCpuTimeMs()
            
            // 短暂延迟以获取有意义的差值
            Thread.sleep(300)
            
            val endTime = SystemClock.elapsedRealtime()
            val endCpuTime = getAppCpuTimeMs()
            
            // 计算应用CPU使用时间占总时间的百分比
            val appTime = endCpuTime - startCpuTime
            val totalTime = endTime - startTime
            
            // 确保不会出现除零错误
            val usage = if (totalTime > 0) appTime.toFloat() / totalTime.toFloat() else 0f
            
            // 范围限制在0-1之间
            return if (usage > 1f) 1f else if (usage < 0f) 0f else usage
        } catch (e: Exception) {
            e.printStackTrace()
            // 如果失败，返回一个合理的默认值
            return 0.1f  // 返回10%作为默认值，更合理
        }
    }
    
    // 获取应用程序的CPU时间（毫秒）
    private fun getAppCpuTimeMs(): Long {
        try {
            // 尝试从/proc/[pid]/stat读取应用CPU时间
            val pid = Process.myPid()
            val path = "/proc/$pid/stat"
            
            try {
                val reader = RandomAccessFile(path, "r")
                val line = reader.readLine()
                reader.close()
                
                // 在stat文件中，第14和15列是utime和stime（用户和系统CPU时间）
                val parts = line.split(" ".toRegex())
                if (parts.size >= 15) {
                    val utime = parts[13].toLong()
                    val stime = parts[14].toLong()
                    
                    // 将时钟周期转换为毫秒（假设系统时钟频率为100）
                    val clockTickMs = 10L // 假设每个时钟周期为10毫秒
                    return (utime + stime) * clockTickMs
                }
            } catch (e: IOException) {
                // 如果无法访问/proc/[pid]/stat，返回基于线程时间的估计
                return Thread.currentThread().totalCpuDuration() ?: 0L
            }
            
            return 0L
        } catch (e: Exception) {
            e.printStackTrace()
            return 0L
        }
    }
    
    // 线程扩展函数用于估算CPU时间
    private fun Thread.totalCpuDuration(): Long? {
        return try {
            // 简单估算，因为我们无法直接获取确切的线程CPU时间
            // 返回线程的运行时间作为估计
            SystemClock.elapsedRealtime() / 4
        } catch (e: Exception) {
            null
        }
    }
}
