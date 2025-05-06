// ChatView.kt
package com.example.trevor_app

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import io.flutter.plugin.platform.PlatformView
import com.genesys.cloud.ui.structure.controller.ChatController
import com.genesys.cloud.integration.messenger.MessengerAccount

internal class ChatView(
  context: Context,
  id: Int,
  creationParams: Map<String, Any?>?
) : PlatformView {

  private val root: View = LayoutInflater
    .from(context)
    .inflate(R.layout.activity_chat, null, false)

  init {
    // pull the country code (or any other params) out of creationParams
    val countryCode = creationParams?.get("countryCode") as? String ?: "US"
    val (deploymentId, domain) = when (countryCode) {
      "MX" -> "08685bd0-dbf1-42d4-bbf9-36e758310409" to "usw2.pure.cloud"
      else -> "8e2f80aa-2cb5-4f54-a764-b638e075531f" to "usw2.pure.cloud"
    }

    val messengerAccount = MessengerAccount(deploymentId, domain).apply {
      logging = true
    }

    ChatController.Builder(context)
      .build(messengerAccount) { result ->
        result.error?.let {
          // handle load error
        } ?: result.fragment?.let { frag ->
          // swap in your chat fragment
          (context as? FlutterFragmentActivity)
            ?.supportFragmentManager
            ?.beginTransaction()
            ?.replace(R.id.chat_container, frag, "chat")
            ?.commit()
        }
      }
  }

  override fun getView(): View = root
  override fun dispose() {}
}
