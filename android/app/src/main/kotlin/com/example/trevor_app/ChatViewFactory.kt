// ChatViewFactory.kt
package com.example.trevor_app

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ChatViewFactory 
  : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  override fun create(
    context: Context,
    viewId: Int,
    args: Any?
  ): PlatformView {
    // correct generic cast—capitalized String & Any
    val params = args as? Map<String, Any?>
    return ChatView(context, viewId, params)
  }
}
