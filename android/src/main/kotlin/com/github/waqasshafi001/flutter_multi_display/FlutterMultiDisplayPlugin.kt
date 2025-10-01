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
                    if (entrypoints != null) {
                        setupMultiDisplay(entrypoints)
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

    private fun setupMultiDisplay(entrypoints: List<String>) {
        val displayManager = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        val displays = displayManager.displays
        Log.d("MultiDisplay", "Detected ${displays.size} displays")

        var index = 0
        for (display in displays) {
            if (display.displayId != Display.DEFAULT_DISPLAY && index < entrypoints.size) {
                showFlutterOnDisplay(display, entrypoints[index])
                index++
            }
        }
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