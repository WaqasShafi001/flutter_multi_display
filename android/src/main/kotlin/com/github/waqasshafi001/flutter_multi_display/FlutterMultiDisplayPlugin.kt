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

/**
 * FlutterMultiDisplayPlugin
 *
 * A Flutter plugin that enables multi-display support for Android applications.
 * This plugin allows Flutter apps to render different UI on multiple physical displays
 * (up to 3 displays: 1 primary + 2 secondary) by creating separate Flutter engines
 * for each display.
 *
 * Features:
 * - Supports up to 3 physical displays simultaneously
 * - Creates independent Flutter engines for each secondary display
 * - Provides shared state management across all displays
 * - Automatically manages engine lifecycle (resume, pause, destroy)
 * - Supports both automatic and port-based display detection
 *
 * The plugin creates a [Presentation] for each secondary display and attaches
 * a [FlutterView] with its own [FlutterEngine], allowing completely independent
 * UI rendering on each screen.
 */

class FlutterMultiDisplayPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var context: Context

    /** Map of active presentations keyed by display ID */
    private val presentations = mutableMapOf<Int, Presentation>()

    /** List of secondary Flutter engines created for additional displays */
    private val secondaryEngines = mutableListOf<FlutterEngine>()

    /** Engine group for efficient engine creation and resource sharing */
    private lateinit var engineGroup: FlutterEngineGroup

    /** List of method channels for communication between Flutter and native code */
    private val channels = mutableListOf<MethodChannel>()


    /**
     * Called when the plugin is attached to the Flutter engine.
     * Initializes the plugin, sets up the method channel, and registers
     * the shared state change listener.
     *
     * @param flutterPluginBinding Provides access to app context and binary messenger
     */
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        engineGroup = FlutterEngineGroup(context)
        val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_multi_display/shared_state")
        channel.setMethodCallHandler(this)
        channels.add(channel)

        // Register listener to propagate state changes to all Flutter engines
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


    /**
     * Handles method calls from Flutter.
     *
     * Supported methods:
     * - `getPlatformVersion`: Returns Android OS version
     * - `updateState`: Updates shared state for a given type
     * - `getState`: Retrieves shared state for a given type
     * - `getAllState`: Retrieves all shared states
     * - `clearState`: Clears shared state for a given type
     * - `setupMultiDisplay`: Initializes multi-display with specified entrypoints
     *
     * @param call Contains the method name and arguments
     * @param result Callback to return the result to Flutter
     */
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

    /**
     * Sets up multi-display by detecting available displays and creating
     * Flutter engines for each secondary display.
     *
     * @param entrypoints List of Dart entrypoint function names (e.g., ["secondDisplay", "thirdDisplay"])
     * @param portBased If true, sorts displays by port type (VGA, HDMI) for predictable assignment
     */
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
             // Skip primary display (DEFAULT_DISPLAY)
            if (display.displayId != Display.DEFAULT_DISPLAY && index < entrypoints.size) {
                showFlutterOnDisplay(display, entrypoints[index])
                index++
            }
        }
    }

    
    /**
     * Sorts displays by port type for predictable display assignment.
     *
     * Order priority:
     * 1. Primary display (DEFAULT_DISPLAY)
     * 2. VGA display (typically for advertisements)
     * 3. Remaining HDMI displays (typically for viewers)
     *
     * This is useful in scenarios where you want consistent display assignments
     * regardless of connection order.
     *
     * @param displays List of all detected displays
     * @return Sorted list of displays
     */
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


    /**
     * Creates and shows a Flutter engine on the specified display.
     *
     * This method:
     * 1. Creates a new Flutter engine from the engine group
     * 2. Runs the specified Dart entrypoint
     * 3. Sets up a method channel for state management
     * 4. Creates a FlutterView and attaches it to the engine
     * 5. Shows the FlutterView in a Presentation on the target display
     *
     * @param display The physical display to show Flutter UI on
     * @param entrypoint The Dart function name to execute (must be a top-level function)
     */
    private fun showFlutterOnDisplay(display: Display, entrypoint: String) {
        val appBundlePath = FlutterInjector.instance().flutterLoader().findAppBundlePath()
        val dartEntrypoint = DartExecutor.DartEntrypoint(appBundlePath, entrypoint)

        val flutterEngine: FlutterEngine = engineGroup.createAndRunEngine(context, dartEntrypoint)
        Log.d("MultiDisplay", "Engine created for $entrypoint")
        secondaryEngines.add(flutterEngine)

        // Create method channel for this engine to communicate with Flutter
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

    /**
     * Called when the app starts or resumes.
     * Resumes all secondary Flutter engines to ensure they continue rendering.
     */
    fun onStart() {
        secondaryEngines.forEach { engine ->
            engine.lifecycleChannel.appIsResumed()
            Log.d("MultiDisplay", "Called appIsResumed on engine for display ${engine.hashCode()}")
        }
    }

    /**
     * Called when the app is paused.
     * Pauses all secondary Flutter engines to save resources.
     */
    fun onStop() {
        secondaryEngines.forEach { engine ->
            engine.lifecycleChannel.appIsPaused()
            Log.d("MultiDisplay", "Called appIsPaused on engine for display ${engine.hashCode()}")
        }
    }

    /**
     * Called when the plugin is detached from the Flutter engine.
     * Cleans up all resources including:
     * - Dismissing all presentations
     * - Destroying all secondary Flutter engines
     * - Clearing all method channels
     *
     * @param binding The plugin binding that is being detached
     */
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