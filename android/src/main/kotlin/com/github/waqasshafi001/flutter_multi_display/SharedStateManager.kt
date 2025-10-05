package com.github.waqasshafi001.flutter_multi_display

import android.os.Handler
import android.os.Looper
import android.util.Log

/**
 * Type alias representing shared state data.
 *
 * A shared state is a nullable map where keys are strings and values can be any type.
 * This flexible structure allows storing various data types including primitives,
 * collections, and nested maps.
 *
 * Example:
 * ```kotlin
 * val userState: SharedState = mapOf(
 *     "name" to "John Doe",
 *     "age" to 30,
 *     "preferences" to mapOf("theme" to "dark", "notifications" to true)
 * )
 * ```
 */
typealias SharedState = Map<String, Any>?

/**
 * Type alias for state change callback functions.
 *
 * Callbacks receive two parameters:
 * @param type The state type identifier that changed (e.g., "userProfile", "cartItems")
 * @param state The new state data, or null if the state was cleared
 *
 * Example:
 * ```kotlin
 * val listener: OnSharedStateChange = { type, state ->
 *     Log.d("StateChange", "State '$type' changed to: $state")
 * }
 * ```
 */
typealias OnSharedStateChange = (type: String, state: SharedState) -> Unit

/**
 * SharedStateManager - Thread-Safe State Management for Multi-Display Applications
 *
 * A singleton object that manages shared state across multiple Flutter engines running
 * on different physical displays. This manager provides a centralized, thread-safe
 * mechanism for storing and synchronizing application state.
 *
 * ## Overview
 *
 * In multi-display Flutter applications, each display runs its own Flutter engine
 * with isolated memory. SharedStateManager bridges these engines by providing a
 * single source of truth for application state that can be accessed from any engine.
 *
 * ## Key Features
 *
 * - **Thread-Safe Operations**: All state operations use synchronized blocks to
 *   prevent race conditions and ensure data consistency
 * - **Observer Pattern**: Supports multiple listeners that are notified when state changes
 * - **Main Thread Callbacks**: All listener callbacks are executed on the main thread
 *   to ensure UI operations are safe
 * - **Automatic Cleanup**: Failed listeners are automatically removed to prevent memory leaks
 * - **Type-Safe Keys**: States are identified by string keys for flexible organization
 *
 * ## Usage Example
 *
 * ```kotlin
 * // Update state from any Flutter engine
 * SharedStateManager.updateState("userProfile", mapOf(
 *     "name" to "John Doe",
 *     "email" to "john@example.com",
 *     "isLoggedIn" to true
 * ))
 *
 * // Register a listener to react to state changes
 * SharedStateManager.addOnStateChangeListener { type, state ->
 *     when (type) {
 *         "userProfile" -> updateUserUI(state)
 *         "cartItems" -> updateCartDisplay(state)
 *     }
 * }
 *
 * // Retrieve state
 * val userProfile = SharedStateManager.getState("userProfile")
 * val userName = (userProfile as? Map<*, *>)?.get("name") as? String
 *
 * // Clear state when no longer needed
 * SharedStateManager.removeState("userProfile")
 * ```
 *
 * ## Architecture
 *
 * The manager maintains two internal collections:
 * 1. `sharedStates`: A map storing all state data keyed by type
 * 2. `listeners`: A set of callback functions to notify on state changes
 *
 * When state changes:
 * 1. State is updated in the synchronized map
 * 2. A copy of listeners is made to avoid concurrent modification
 * 3. Each listener is invoked on the main thread
 * 4. Failed listeners are automatically removed
 *
 * ## Thread Safety
 *
 * All public methods that access or modify state use `synchronized(this)` blocks
 * to ensure thread-safe operation. This allows state updates from any thread
 * (including background threads) without risk of data corruption.
 *
 * ## Memory Management
 *
 * - Listeners that throw exceptions are automatically removed
 * - The `reset()` method clears all state and listeners for testing/cleanup
 * - No explicit cleanup is needed for normal operation
 *
 * @see SharedState
 * @see OnSharedStateChange
 */
object SharedStateManager {
    private const val TAG = "SharedStateManager"

    /**
     * Internal map storing all shared states.
     *
     * Keys are state type identifiers (e.g., "userProfile", "appSettings").
     * Values are nullable maps containing the actual state data.
     *
     * Thread-safety is ensured through synchronized blocks in all accessor methods.
     */
    private val sharedStates = mutableMapOf<String, SharedState>()
    
    /**
     * Set of registered state change listeners.
     *
     * Each listener is called when any state changes. Listeners that throw
     * exceptions are automatically removed to prevent cascading failures.
     */
    private val listeners = mutableSetOf<OnSharedStateChange>()

    /**
     * Handler for posting callbacks to the main thread.
     *
     * Ensures all listener callbacks are executed on the main (UI) thread,
     * making it safe to perform UI updates directly in listener code.
     */
    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * Updates the shared state for a specific type and notifies all listeners.
     *
     * This is the primary method for modifying state. When called:
     * 1. The state is stored in the synchronized map
     * 2. Change is logged for debugging
     * 3. All registered listeners are notified on the main thread
     *
     * If the state for this type already exists, it will be overwritten.
     *
     * ## Thread Safety
     * This method is thread-safe and can be called from any thread.
     *
     * ## Example
     * ```kotlin
     * // Update user profile
     * SharedStateManager.updateState("userProfile", mapOf(
     *     "id" to 12345,
     *     "name" to "Jane Smith",
     *     "role" to "admin"
     * ))
     *
     * // Update shopping cart
     * SharedStateManager.updateState("cart", mapOf(
     *     "items" to listOf(
     *         mapOf("id" to "P1", "quantity" to 2),
     *         mapOf("id" to "P2", "quantity" to 1)
     *     ),
     *     "total" to 149.99
     * ))
     *
     * // Clear a state by setting it to null
     * SharedStateManager.updateState("temporaryData", null)
     * ```
     *
     * @param type The state type identifier. Should be a unique string describing
     *             the state (e.g., "userProfile", "cartItems", "appSettings")
     * @param state The state data as a nullable map. Pass null to clear the state
     *              while still triggering listener notifications
     */
    fun updateState(type: String, state: SharedState) {
        synchronized(this) {
            sharedStates[type] = state
            Log.d(TAG, "State updated: $type = $state")
            Log.d(TAG, "Complete states: $sharedStates")
        }
        notifyListeners(type, state)
    }

    /**
     * Retrieves the shared state for a specific type.
     *
     * Returns the current state data for the given type, or null if:
     * - The type hasn't been set yet
     * - The type was explicitly set to null
     * - The type was removed via [removeState]
     *
     * ## Thread Safety
     * This method is thread-safe and can be called from any thread.
     *
     * ## Example
     * ```kotlin
     * // Get user profile state
     * val profileState = SharedStateManager.getState("userProfile")
     * if (profileState != null) {
     *     val name = profileState["name"] as? String
     *     val email = profileState["email"] as? String
     *     Log.d("User", "Name: $name, Email: $email")
     * } else {
     *     Log.d("User", "No profile data available")
     * }
     *
     * // Safe casting example
     * val cartState = SharedStateManager.getState("cart")
     * val items = (cartState?.get("items") as? List<*>)?.size ?: 0
     * Log.d("Cart", "Total items: $items")
     * ```
     *
     * @param type The state type identifier to retrieve. If null is passed,
     *             the method returns null and logs a warning
     * @return The state data as a map, or null if the type doesn't exist,
     *         is null, or hasn't been set
     */
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

    /**
     * Retrieves all shared states as a snapshot copy.
     *
     * Returns a new HashMap containing all current states. The returned map
     * is a copy, so modifications to it won't affect the internal state storage.
     * This prevents concurrent modification issues and allows safe iteration.
     *
     * ## Use Cases
     * - Debugging: Inspect all current states
     * - State persistence: Save all states to disk
     * - State migration: Transfer states between engines
     * - Logging: Record complete application state
     *
     * ## Thread Safety
     * This method is thread-safe and can be called from any thread.
     *
     * ## Example
     * ```kotlin
     * // Get all states for debugging
     * val allStates = SharedStateManager.getAllState()
     * Log.d("States", "Total state types: ${allStates.size}")
     * allStates.forEach { (type, state) ->
     *     Log.d("States", "$type: $state")
     * }
     *
     * // Check if specific states exist
     * val hasUserProfile = allStates.containsKey("userProfile")
     * val hasCart = allStates.containsKey("cart")
     * Log.d("States", "User logged in: $hasUserProfile, Cart active: $hasCart")
     *
     * // Count non-null states
     * val activeStates = allStates.values.count { it != null }
     * Log.d("States", "Active states: $activeStates")
     * ```
     *
     * @return A HashMap containing all state types as keys and their corresponding
     *         state data as values. Returns an empty map if no states exist
     */
    fun getAllState(): Map<String, SharedState> {
        synchronized(this) {
            val stateCopy = HashMap(sharedStates)
            Log.d(TAG, "getAllState called, returning: $stateCopy")
            return stateCopy
        }
    }

    /**
     * Removes a specific state type and notifies listeners.
     *
     * This method permanently removes the state from the manager and notifies
     * all listeners with a null value. Use this when a state is no longer needed
     * rather than setting it to null, as it frees memory.
     *
     * If the specified type doesn't exist, this method does nothing except
     * log a debug message.
     *
     * ## Thread Safety
     * This method is thread-safe and can be called from any thread.
     *
     * ## Example
     * ```kotlin
     * // Remove user session after logout
     * SharedStateManager.removeState("userSession")
     *
     * // Clear temporary checkout data after order completion
     * SharedStateManager.removeState("checkoutData")
     *
     * // Remove multiple states
     * listOf("tempCache", "uploadProgress", "draftData").forEach { type ->
     *     SharedStateManager.removeState(type)
     * }
     * ```
     *
     * ## Difference from updateState(type, null)
     * - `removeState(type)`: Removes the key entirely from the map
     * - `updateState(type, null)`: Keeps the key but sets value to null
     *
     * Both notify listeners with null, but `removeState` frees the key memory.
     *
     * @param type The state type identifier to remove. If this type doesn't
     *             exist in the state map, the method returns early without
     *             notifying listeners
     */
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

    /**
     * Registers a listener to receive state change notifications.
     *
     * The listener will be called whenever ANY state is updated or removed.
     * Callbacks are guaranteed to execute on the main (UI) thread, making it
     * safe to update UI elements directly in the callback.
     *
     * ## Listener Lifecycle
     * - Listeners remain registered until explicitly removed via [removeOnStateChangeListener]
     * - Listeners that throw exceptions are automatically removed
     * - Multiple listeners can be registered for the same state changes
     *
     * ## Thread Safety
     * This method is thread-safe and can be called from any thread.
     *
     * ## Example
     * ```kotlin
     * // Register a listener for all state changes
     * SharedStateManager.addOnStateChangeListener { type, state ->
     *     when (type) {
     *         "userProfile" -> {
     *             // Update user UI on all displays
     *             val name = (state as? Map<*, *>)?.get("name") as? String
     *             updateUserDisplay(name)
     *         }
     *         "cart" -> {
     *             // Sync cart across displays
     *             val itemCount = (state as? Map<*, *>)?.get("itemCount") as? Int ?: 0
     *             updateCartBadge(itemCount)
     *         }
     *         "appSettings" -> {
     *             // Apply new settings
     *             applySettings(state)
     *         }
     *     }
     * }
     *
     * // Store listener reference for later removal
     * val cartListener: OnSharedStateChange = { type, state ->
     *     if (type == "cart") {
     *         updateCartUI(state)
     *     }
     * }
     * SharedStateManager.addOnStateChangeListener(cartListener)
     * // Later: SharedStateManager.removeOnStateChangeListener(cartListener)
     * ```
     *
     * ## Important Notes
     * - Callbacks execute on the main thread - avoid long-running operations
     * - State parameter can be null if the state was cleared or removed
     * - Type parameter is always non-null and identifies which state changed
     * - Exceptions thrown in listeners won't crash the app but will remove the listener
     *
     * @param listener The callback function to invoke when any state changes.
     *                 The callback receives the state type and new state data (or null)
     */
    fun addOnStateChangeListener(listener: OnSharedStateChange) {
        synchronized(this) {
            listeners.add(listener)
            Log.d(TAG, "Listener added. Total: ${listeners.size}")
        }
    }

    /**
     * Unregisters a previously registered state change listener.
     *
     * Removes the specified listener from the notification list. After removal,
     * the listener will no longer receive state change notifications.
     *
     * If the listener isn't currently registered, this method does nothing.
     *
     * ## Thread Safety
     * This method is thread-safe and can be called from any thread.
     *
     * ## Example
     * ```kotlin
     * // Store listener reference when adding
     * val profileListener: OnSharedStateChange = { type, state ->
     *     if (type == "userProfile") {
     *         updateProfileUI(state)
     *     }
     * }
     * SharedStateManager.addOnStateChangeListener(profileListener)
     *
     * // Later, when the listener is no longer needed
     * SharedStateManager.removeOnStateChangeListener(profileListener)
     *
     * // In activity/fragment lifecycle
     * override fun onDestroy() {
     *     super.onDestroy()
     *     SharedStateManager.removeOnStateChangeListener(myListener)
     * }
     * ```
     *
     * ## Memory Management
     * Always remove listeners when they're no longer needed (e.g., in onDestroy)
     * to prevent memory leaks, especially if the listener references an
     * activity, fragment, or other lifecycle-aware component.
     *
     * @param listener The callback function to unregister. Must be the exact
     *                 same reference that was passed to [addOnStateChangeListener]
     */
    fun removeOnStateChangeListener(listener: OnSharedStateChange) {
        synchronized(this) {
            listeners.remove(listener)
            Log.d(TAG, "Listener removed. Total: ${listeners.size}")
        }
    }

    /**
     * Notifies all registered listeners about a state change.
     *
     * This internal method is called by [updateState] and [removeState] to
     * propagate changes to all registered listeners. It ensures:
     * 1. Listeners are called on the main thread
     * 2. Failed listeners are automatically removed
     * 3. Concurrent modification is prevented
     *
     * ## Execution Flow
     * 1. Check if there are any listeners (return early if none)
     * 2. Create a copy of the listener set to prevent concurrent modification
     * 3. Post a runnable to the main thread handler
     * 4. Iterate through listeners, invoking each one
     * 5. Catch and log any exceptions
     * 6. Remove failed listeners to prevent repeated failures
     * 7. Log success and failure counts
     *
     * ## Error Handling
     * If a listener throws an exception:
     * - The exception is logged with a stack trace
     * - The listener is removed from the set
     * - Other listeners continue to execute normally
     *
     * ## Performance Considerations
     * - Listener count is checked before creating the copy
     * - Notification happens asynchronously on the main thread
     * - Failed listeners are removed to prevent future overhead
     *
     * @param type The state type that changed
     * @param state The new state value, or null if the state was cleared/removed
     */
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

    /**
     * Resets the manager by clearing all states and listeners.
     *
     * **WARNING**: This is a destructive operation that should only be used for:
     * - Unit testing setup/teardown
     * - Application reset scenarios
     * - Memory cleanup before app termination
     *
     * After calling this method:
     * - All state data is permanently lost
     * - All registered listeners are removed (won't be notified)
     * - The manager returns to its initial empty state
     *
     * ## Thread Safety
     * This method is thread-safe and can be called from any thread.
     *
     * ## Example
     * ```kotlin
     * // In unit tests
     * @Before
     * fun setUp() {
     *     SharedStateManager.reset()
     * }
     *
     * @After
     * fun tearDown() {
     *     SharedStateManager.reset()
     * }
     *
     * // For app logout/reset
     * fun logout() {
     *     SharedStateManager.reset() // Clear all user data
     *     navigateToLogin()
     * }
     * ```
     *
     * ## Important Notes
     * - This method does NOT notify listeners about the cleared states
     * - Use with caution in production code
     * - Consider removing specific states instead if possible
     */
    fun reset() {
        synchronized(this) {
            Log.w(TAG, "Resetting - clearing all states and listeners")
            sharedStates.clear()
            listeners.clear()
        }
    }

    /**
     * Returns the current number of registered listeners.
     *
     * This method is primarily useful for:
     * - Debugging listener registration/cleanup
     * - Unit testing listener management
     * - Monitoring memory usage
     * - Verifying listener cleanup in lifecycle methods
     *
     * ## Thread Safety
     * This method is thread-safe and can be called from any thread.
     *
     * ## Example
     * ```kotlin
     * // Debugging
     * Log.d("Listeners", "Active listeners: ${SharedStateManager.getListenerCount()}")
     *
     * // Unit test verification
     * @Test
     * fun testListenerCleanup() {
     *     val listener: OnSharedStateChange = { _, _ -> }
     *     SharedStateManager.addOnStateChangeListener(listener)
     *     assertEquals(1, SharedStateManager.getListenerCount())
     *
     *     SharedStateManager.removeOnStateChangeListener(listener)
     *     assertEquals(0, SharedStateManager.getListenerCount())
     * }
     *
     * // Memory leak detection
     * fun checkForLeaks() {
     *     val count = SharedStateManager.getListenerCount()
     *     if (count > expectedListeners) {
     *         Log.w("MemoryLeak", "Unexpected listener count: $count")
     *     }
     * }
     * ```
     *
     * @return The number of currently registered listeners. Returns 0 if no
     *         listeners are registered or if [reset] was called
     */
    fun getListenerCount(): Int {
        synchronized(this) {
            return listeners.size
        }
    }
}