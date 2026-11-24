package com.kitabkhana.kitabkhana

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The app pushes what the home-screen widget shows; nothing else
        // reads it. See ReadingWidgetProvider.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ReadingWidgetProvider.CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "update" -> {
                        @Suppress("UNCHECKED_CAST")
                        val data = call.arguments as? Map<String, Any?> ?: emptyMap()
                        ReadingWidgetProvider.save(applicationContext, data)
                        ReadingWidgetProvider.refreshAll(applicationContext)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
