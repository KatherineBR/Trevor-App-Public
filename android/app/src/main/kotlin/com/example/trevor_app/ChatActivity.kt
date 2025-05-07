package com.example.trevor_app

import android.os.Bundle
import android.util.Log
import android.widget.ImageButton
import androidx.appcompat.app.AppCompatActivity
import com.genesys.cloud.integration.messenger.MessengerAccount
import com.genesys.cloud.ui.structure.controller.*

class ChatActivity : AppCompatActivity() {
    companion object {
        private const val TAG = "TrevorAppChat"
    }

    private var chatController: ChatController? = null
    private var deploymentId: String? = null
    private var domain: String? = null
    private var fcmToken: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_chat)

        // Get deployment info from intent
        deploymentId = intent.getStringExtra("deploymentId")
        domain = intent.getStringExtra("domain")
        fcmToken = intent.getStringExtra("fcmToken")

        if (deploymentId == null || domain == null) {
            Log.e(TAG, "Missing deployment information")
            finish()
            return
        }

        initializeChat()
    }

    private fun initializeChat() {
        val activity = this
        
        val messengerAccount = MessengerAccount(deploymentId!!, domain!!).apply {
            logging = true
        }

        chatController = ChatController.Builder(this).build(messengerAccount, object : ChatLoadedListener {
            override fun onComplete(result: ChatLoadResponse) {
                result.error?.let {
                    Log.d(TAG, "Chat failed to load")
                } ?: run {
                    result.fragment?.let {
                        activity.supportFragmentManager.beginTransaction()
                            .replace(R.id.chat_container, it, TAG)
                            .commit()
                    }
                }
            }
        })

        if(fcmToken != null){
            print("setting token")
            MessengerAccount
        }

        // Set up back button
        val backButton: ImageButton = findViewById(R.id.btn_back)
        backButton.setOnClickListener {
            Log.d(TAG, "Back button clicked, returning to Flutter UI")
            // Optional: Clean up chat resources if needed
            // chatController?.clearConversation()
            // Close this activity and return to Flutter
            finish()
        }
    }

    override fun onBackPressed() {
        // Optional: Clean up chat resources if needed
        // TODO: Clearconversation doesn't work for some reason
        // chatController?.clearConversation()
        
        // Close this activity and return to Flutter
        finish()
    }
}