package com.github.waqasshafi001.flutter_multi_display

import android.app.Presentation
import android.content.Context
import android.hardware.display.DisplayManager
import android.os.Bundle
import android.util.Log
import android.view.Display
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.FlutterInjector

class FlutterMultiDisplayPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var context: Context
    private val presentations = mutableMapOf<Int, Presentation>()
    private val secondaryEngines = mutableListOf<FlutterEngine>()
    private lateinit var engineGroup: FlutterEngineGroup
    private val channels = mutableListOf<MethodChannel>()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        engineGroup = FlutterEngineGroup(context)
        val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_multi_display/shared_state")
        channel.setMethodCallHandler(this)
        channels.add(channel)
        SharedStateManager.addOnStateChangeListener { type, state ->
            Log.d("SharedState", "Notifying all channels: type=$type, state=$state")
            for (ch in channels) {
                ch.invokeMethod("onStateChanged", mapOf("type" to type, "data" to state))
                Log.d("SharedState", "Invoked onStateChanged on channel (total channels: ${channels.size})")
            }
        }
        // Ensure secondary engines are resumed
        onStart()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android " + android.os.Build.VERSION.RELEASE)
                }
                "updateState" -> {
                    val type = call.argument<String>("type")
                    val state = call.argument<Map<String, Any>?>("state")
                    if (type != null) {
                        SharedStateManager.updateState(type, state)
                        Log.d("SharedState", "updateState: $type = $state")
                        result.success(null)
                    } else {
                        result.error("INVALID_TYPE", "Type cannot be null", null)
                    }
                }
                "getState" -> {
                    val type = call.argument<String>("type")
                    val value = SharedStateManager.getState(type)
                    Log.d("SharedState", "getState: $type = $value")
                    result.success(value)
                }
                "getAllState" -> {
                    val allState = SharedStateManager.getAllState()
                    Log.d("SharedState", "getAllState: $allState")
                    result.success(allState)
                }
                "clearState" -> {
                    val type = call.argument<String>("type")
                    if (type != null) {
                        SharedStateManager.removeState(type)
                        Log.d("SharedState", "clearState: $type")
                        result.success(null)
                    } else {
                        result.error("INVALID_TYPE", "Type cannot be null", null)
                    }
                }
                "setupMultiDisplay" -> {
                    val entrypoints = call.argument<List<String>>("entrypoints")
                    val portBased = call.argument<Boolean>("portBased") ?: false
                    if (entrypoints != null) {
                        setupMultiDisplay(entrypoints, portBased)
                        result.success(null)
                    } else {
                        result.error("INVALID_ENTRYPOINTS", "Entrypoints cannot be null", null)
                    }
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            Log.e("SharedState", "Error in method call", e)
            result.error("ERR", e.message, null)
        }
    }

    private fun setupMultiDisplay(entrypoints: List<String>, portBased: Boolean) {
        val displayManager = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        var displays = displayManager.displays.toList()
        Log.d("MultiDisplay", "Detected ${displays.size} displays")
        // Log detailed display info
        for (display in displays) {
            val displayMode = display.supportedModes.firstOrNull()
            Log.d(
                "MultiDisplay",
                "Display ID: ${display.displayId}, Name: ${display.name}, " +
                "RefreshRate: ${displayMode?.refreshRate}, " +
                "Flags: ${display.flags}"
            )
        }

        if (portBased) {
            displays = sortDisplaysByPort(displays)
        }

        var index = 0
        for (display in displays) {
            if (display.displayId != Display.DEFAULT_DISPLAY && index < entrypoints.size) {
                showFlutterOnDisplay(display, entrypoints[index])
                index++
            }
        }
    }

    private fun sortDisplaysByPort(displays: List<Display>): List<Display> {
        val sortedDisplays = mutableListOf<Display>()

        // Log all display names for debugging
        for (display in displays) {
            Log.d("MultiDisplay", "Display ID: ${display.displayId}, Name: ${display.name}, Flags: ${display.flags}, SupportedModes: ${display.supportedModes.joinToString { "${it.refreshRate}" }}")
        }

        // Primary display (usually built-in or first HDMI) is always first
        val primary = displays.find { it.displayId == Display.DEFAULT_DISPLAY }
        if (primary != null) {
            sortedDisplays.add(primary)
        }

        // Assign VGA for Ads (screenId: 2)
        val vgaDisplay = displays.find { it.name.contains("VGA", ignoreCase = true) }
        if (vgaDisplay != null) {
            sortedDisplays.add(vgaDisplay)
        }

        // Assign remaining HDMI for Viewer (screenId: 3)
        val remainingDisplays = displays.filter { it.displayId != Display.DEFAULT_DISPLAY && it != vgaDisplay }
        sortedDisplays.addAll(remainingDisplays)
        remainingDisplays.forEach {
            Log.d("MultiDisplay", "Assigned remaining display: ID=${it.displayId}, Name=${it.name}")
        }

        return sortedDisplays
    }

    private fun showFlutterOnDisplay(display: Display, entrypoint: String) {
        val appBundlePath = FlutterInjector.instance().flutterLoader().findAppBundlePath()
        val dartEntrypoint = DartExecutor.DartEntrypoint(appBundlePath, entrypoint)

        val flutterEngine: FlutterEngine = engineGroup.createAndRunEngine(context, dartEntrypoint)
        Log.d("MultiDisplay", "Engine created for $entrypoint")
        secondaryEngines.add(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flutter_multi_display/shared_state")
        channel.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "updateState" -> {
                        val type = call.argument<String>("type")
                        val state = call.argument<Map<String, Any>?>("state")
                        if (type != null) {
                            SharedStateManager.updateState(type, state)
                            Log.d("SharedState", "updateState: $type = $state")
                            result.success(null)
                        } else {
                            result.error("INVALID_TYPE", "Type cannot be null", null)
                        }
                    }
                    "getState" -> {
                        val type = call.argument<String>("type")
                        val value = SharedStateManager.getState(type)
                        Log.d("SharedState", "getState: $type = $value")
                        result.success(value)
                    }
                    "getAllState" -> {
                        val allState = SharedStateManager.getAllState()
                        Log.d("SharedState", "getAllState: $allState")
                        result.success(allState)
                    }
                    "clearState" -> {
                        val type = call.argument<String>("type")
                        if (type != null) {
                            SharedStateManager.removeState(type)
                            Log.d("SharedState", "clearState: $type")
                            result.success(null)
                        } else {
                            result.error("INVALID_TYPE", "Type cannot be null", null)
                        }
                    }
                    "getPlatformVersion" -> {
                        result.success("Android " + android.os.Build.VERSION.RELEASE)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                Log.e("SharedState", "Error in method call", e)
                result.error("ERR", e.message, null)
            }
        }

        channels.add(channel)

        val flutterView = FlutterView(context)
        flutterView.attachToFlutterEngine(flutterEngine)

        val presentation = object : Presentation(context, display) {
            override fun onCreate(savedInstanceState: Bundle?) {
                super.onCreate(savedInstanceState)
                setContentView(flutterView)
            }
        }

        presentation.show()
        presentations[display.displayId] = presentation

        // Ensure the engine is resumed
        flutterEngine.lifecycleChannel.appIsResumed()
        Log.d("MultiDisplay", "Started Flutter engine on display ${display.displayId} with entrypoint $entrypoint")
    }

    fun onStart() {
        secondaryEngines.forEach { engine ->
            engine.lifecycleChannel.appIsResumed()
            Log.d("MultiDisplay", "Called appIsResumed on engine for display ${engine.hashCode()}")
        }
    }

    fun onStop() {
        secondaryEngines.forEach { engine ->
            engine.lifecycleChannel.appIsPaused()
            Log.d("MultiDisplay", "Called appIsPaused on engine for display ${engine.hashCode()}")
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channels.clear()
        presentations.values.forEach { it.dismiss() }
        presentations.clear()
        secondaryEngines.forEach { engine ->
            engine.lifecycleChannel.appIsDetached()
            engine.destroy()
            Log.d("MultiDisplay", "Destroyed engine for display ${engine.hashCode()}")
        }
        secondaryEngines.clear()
    }
}