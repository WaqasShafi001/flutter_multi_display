package com.github.waqasshafi001.flutter_multi_display_example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.github.waqasshafi001.flutter_multi_display.FlutterMultiDisplayPlugin

class MainActivity : FlutterActivity() {
    private var multiDisplayPlugin: FlutterMultiDisplayPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Store reference to FlutterMultiDisplayPlugin
        multiDisplayPlugin = flutterEngine.plugins.get(FlutterMultiDisplayPlugin::class.java) as? FlutterMultiDisplayPlugin
        // Call setupMultiDisplay as before
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flutter_multi_display/shared_state")
        channel.invokeMethod("setupMultiDisplay", mapOf("entrypoints" to listOf("screen1Main", "screen2Main")))
    }

    override fun onStart() {
        super.onStart()
        // Call onStart on the plugin to resume secondary engines
        multiDisplayPlugin?.onStart()
    }

    override fun onStop() {
        super.onStop()
        // Call onStop on the plugin to pause secondary engines
        multiDisplayPlugin?.onStop()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        // Clear the plugin reference
        multiDisplayPlugin = null
    }
}