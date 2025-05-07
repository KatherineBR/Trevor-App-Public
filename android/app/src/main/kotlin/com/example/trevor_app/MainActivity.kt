package com.example.trevor_app

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainAlias
class TrevorAlias

class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val CHANNEL = "com.trevor.app/kotlin"
        private const val TAG = "TrevorApp"
    }

    override fun onCreate(savedInstanceState: Bundle?) {        
        // Secure screen when switching tabs
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "Configuring Flutter engine and setting up method channel")
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                Log.d(TAG, "Received method call: ${call.method}")
                    
                when (call.method) {
                    "switchAppIcon" -> {
                        // Get the argument first, then log it
                        val useTrevorIcon = call.argument<Boolean>("useTrevorIcon") ?: false
                        Log.d(TAG, "Switching app icon. Use Trevor icon: $useTrevorIcon")
                        
                        switchAppIcon(useTrevorIcon)
                        result.success(null)
                    }
                    "getChatUS" -> {
                        Log.d(TAG, "Launching US chat")
                        launchChat("8e2f80aa-2cb5-4f54-a764-b638e075531f", "usw2.pure.cloud")
                        result.success(null)
                    }
                    "getChatMX" -> {
                        Log.d(TAG, "Launching MX chat")
                        launchChat("08685bd0-dbf1-42d4-bbf9-36e758310409", "usw2.pure.cloud")
                        result.success(null)
                    }
                    else -> {
                        Log.d(TAG, "Method not implemented: ${call.method}")
                        result.notImplemented()
                    }
                }
            }
    }

    private fun launchChat(deploymentId: String, domain: String) {
        val intent = Intent(this, ChatActivity::class.java).apply {
            putExtra("deploymentId", deploymentId)
            putExtra("domain", domain)
            // These flags ensure proper activity stack management
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        startActivity(intent)
    }

    private fun switchAppIcon(useTrevorIcon: Boolean) {
        val pm: PackageManager = packageManager
        val packageName = packageName
        Log.d(TAG, "Package name: $packageName")

        // Construct component names for the aliases. These must match what you've declared in your manifest.
        val aliasStar = ComponentName(packageName, "$packageName.MainAlias")
        val aliasTrevor = ComponentName(packageName, "$packageName.TrevorAlias")
        
        Log.d(TAG, "Star alias: ${aliasStar.className}")
        Log.d(TAG, "Trevor alias: ${aliasTrevor.className}")

        try {
            if (useTrevorIcon) {
                Log.d(TAG, "Enabling Trevor icon, disabling Star icon")
                pm.setComponentEnabledSetting(
                    aliasStar,
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
                pm.setComponentEnabledSetting(
                    aliasTrevor,
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                    PackageManager.DONT_KILL_APP
                )
            } else {
                Log.d(TAG, "Enabling Star icon, disabling Trevor icon")
                pm.setComponentEnabledSetting(
                    aliasTrevor,
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
                pm.setComponentEnabledSetting(
                    aliasStar,
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                    PackageManager.DONT_KILL_APP
                )
            }
            Log.d(TAG, "App icon switching completed successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error switching app icon", e)
            e.printStackTrace() // This will print the stack trace to the console
        }
    }
}