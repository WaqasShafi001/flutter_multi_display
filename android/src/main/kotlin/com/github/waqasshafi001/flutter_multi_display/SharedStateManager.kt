package com.github.waqasshafi001.flutter_multi_display

import android.os.Handler
import android.os.Looper
import android.util.Log

typealias SharedState = Map<String, Any>?
typealias OnSharedStateChange = (type: String, state: SharedState) -> Unit

object SharedStateManager {
    private const val TAG = "SharedStateManager"

    private val sharedStates = mutableMapOf<String, SharedState>()
    private val listeners = mutableSetOf<OnSharedStateChange>()

    private val mainHandler = Handler(Looper.getMainLooper())

    fun updateState(type: String, state: SharedState) {
        synchronized(this) {
            sharedStates[type] = state
            Log.d(TAG, "State updated: $type = $state")
            Log.d(TAG, "Complete states: $sharedStates")
        }
        notifyListeners(type, state)
    }

    fun getState(type: String?): SharedState {
        if (type == null) {
            Log.w(TAG, "getState called with null type")
            return null
        }
        synchronized(this) {
            val value = sharedStates[type]
            Log.d(TAG, "getState: $type = $value")
            return value
        }
    }

    fun getAllState(): Map<String, SharedState> {
        synchronized(this) {
            val stateCopy = HashMap(sharedStates)
            Log.d(TAG, "getAllState called, returning: $stateCopy")
            return stateCopy
        }
    }

    fun removeState(type: String) {
        synchronized(this) {
            if (!sharedStates.containsKey(type)) {
                Log.d(TAG, "removeState: $type not found")
                return
            }
            sharedStates.remove(type)
            Log.d(TAG, "State removed: $type")
        }
        notifyListeners(type, null)
    }

    fun addOnStateChangeListener(listener: OnSharedStateChange) {
        synchronized(this) {
            listeners.add(listener)
            Log.d(TAG, "Listener added. Total: ${listeners.size}")
        }
    }

    fun removeOnStateChangeListener(listener: OnSharedStateChange) {
        synchronized(this) {
            listeners.remove(listener)
            Log.d(TAG, "Listener removed. Total: ${listeners.size}")
        }
    }

    private fun notifyListeners(type: String, state: SharedState) {
        synchronized(this) {
            if (listeners.isEmpty()) {
                Log.d(TAG, "No listeners to notify")
                return
            }
            val listenersCopy = listeners.toList()
            mainHandler.post {
                var successCount = 0
                var failureCount = 0
                for (listener in listenersCopy) {
                    try {
                        listener(type, state)
                        successCount++
                    } catch (e: Exception) {
                        failureCount++
                        Log.e(TAG, "Error notifying listener", e)
                        synchronized(this@SharedStateManager) {
                            listeners.remove(listener)
                        }
                    }
                }
                Log.d(TAG, "Notification: $successCount success, $failureCount failed")
            }
        }
    }

    fun reset() {
        synchronized(this) {
            Log.w(TAG, "Resetting - clearing all states and listeners")
            sharedStates.clear()
            listeners.clear()
        }
    }

    fun getListenerCount(): Int {
        synchronized(this) {
            return listeners.size
        }
    }
}