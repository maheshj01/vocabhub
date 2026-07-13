package com.vocabhub.app

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val restartChannel = "com.vocabhub.app/restart"
    private val restartMethod = "restart"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Lets Flutter relaunch the app after applying a Shorebird patch.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, restartChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    restartMethod -> {
                        Log.d("MainActivity", "Restart requested from Flutter")
                        scheduleAppRestart()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun scheduleAppRestart() {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val mainIntent = Intent.makeRestartActivityTask(launchIntent?.component)
        startActivity(mainIntent)
        Runtime.getRuntime().exit(0)
    }
}
