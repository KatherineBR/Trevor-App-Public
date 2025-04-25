package com.example.trevor_app

import android.os.Bundle
import android.content.ComponentName
import android.content.pm.PackageManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import com.genesys.cloud.integration.messenger.MessengerAccount
import com.genesys.cloud.ui.structure.controller.*

class MainAlias
class TrevorAlias

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.trevor.app/kotlin"
        private const val TAG = "TrevorApp"
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {        
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
                
                if (call.method == "switchAppIcon") {
                    // Get the argument first, then log it
                    val useTrevorIcon = call.argument<Boolean>("useTrevorIcon") ?: false
                    Log.d(TAG, "Switching app icon. Use Trevor icon: $useTrevorIcon")
                    
                    switchAppIcon(useTrevorIcon)
                    result.success(null)
                } else if (call.method == "getChat"){
                    Log.d(TAG, "Getting messaging")
                } else {
                    Log.d(TAG, "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
    
    }

    private fun getChat(){
        val deploymentId = "8e2f80aa-2cb5-4f54-a764-b638e075531f"
        val domain = "https://apps.mypurecloud.com"
        setContentView(R.layout.activity_chat)
        val activity = context as? AppCompatActivity
        
        val messengerAccount = MessengerAccount(deploymentId, domain).apply {
            logging = true
        }

        val chatController = ChatController.Builder(this).build(messengerAccount, object : ChatLoadedListener {
            override fun onComplete(result: ChatLoadResponse) {
                result.error?.let {
                    Log.d(TAG, "Chat failed to load")
                } ?: run {
                    result.fragment?.let {
                        activity?.supportFragmentManager?.beginTransaction()
                            ?.replace(R.id.chat_container, it, TAG)
                            ?.commit()
                    }
                }
            }
        })
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