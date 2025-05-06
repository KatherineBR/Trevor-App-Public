package com.example.trevor_app

import com.example.trevor_app.R

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import com.example.trevor_app.R
import com.genesys.cloud.integration.messenger.MessengerAccount
import com.genesys.cloud.ui.structure.controller.ChatController
import com.genesys.cloud.ui.structure.controller.ChatLoadResponse
import com.genesys.cloud.ui.structure.controller.ChatLoadedListener
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

// 1. MainActivity: registers MethodChannel and PlatformViewFactory
class MainActivity : FlutterFragmentActivity() {
  companion object {
    private const val CHANNEL = "com.trevor.app/kotlin"
    private const val VIEW_TYPE = "com.trevor.app/chat_view"
    private const val TAG = "TrevorApp"
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    // Secure screen when switching tabs
    window.setFlags(
      WindowManager.LayoutParams.FLAG_SECURE,
      WindowManager.LayoutParams.FLAG_SECURE
    )
    super.onCreate(savedInstanceState)
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    // Register the chat view factory
    flutterEngine.platformViewsController.registry.registerViewFactory(
      VIEW_TYPE,
      ChatPlatformViewFactory(flutterEngine.dartExecutor.binaryMessenger)
    )

    // Handle icon-switch and (if desired) central chat calls
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "switchAppIcon" -> {
            val useTrevorIcon = call.argument<Boolean>("useTrevorIcon") ?: false
            switchAppIcon(useTrevorIcon)
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
  }

  private fun switchAppIcon(useTrevorIcon: Boolean) {
    val pm = packageManager
    val pkg = packageName
    val aliasMain = ComponentName(pkg, "${pkg}.MainAlias")
    val aliasTrevor = ComponentName(pkg, "${pkg}.TrevorAlias")

    if (useTrevorIcon) {
      pm.setComponentEnabledSetting(
        aliasMain,
        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
        PackageManager.DONT_KILL_APP
      )
      pm.setComponentEnabledSetting(
        aliasTrevor,
        PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
        PackageManager.DONT_KILL_APP
      )
    } else {
      pm.setComponentEnabledSetting(
        aliasTrevor,
        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
        PackageManager.DONT_KILL_APP
      )
      pm.setComponentEnabledSetting(
        aliasMain,
        PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
        PackageManager.DONT_KILL_APP
      )
    }
    Log.d(TAG, "App icon switched to Trevor? $useTrevorIcon")
  }
}

// 2. ChatFragment: your existing Genesys chat flows in a Fragment
class ChatFragment : Fragment() {
  companion object {
    private const val ARG_COUNTRY = "countryCode"
    private const val TAG = "TrevorAppChat"

    fun newInstance(country: String) = ChatFragment().apply {
      arguments = Bundle().apply { putString(ARG_COUNTRY, country) }
    }
  }

  override fun onCreateView(
    inflater: LayoutInflater,
    container: ViewGroup?,
    savedInstanceState: Bundle?
  ): View? = inflater.inflate(R.layout.activity_chat, container, false)

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)
    val country = arguments?.getString(ARG_COUNTRY) ?: "US"
    if (country == "US") getChatUS() else getChatMX()
  }

  private fun getChatUS() {
    val deploymentId = "8e2f80aa-2cb5-4f54-a764-b638e075531f"
    val domain = "usw2.pure.cloud"
    val account = MessengerAccount(deploymentId, domain).apply { logging = true }

    ChatController.Builder(requireContext())
      .build(account, object : ChatLoadedListener {
        override fun onComplete(result: ChatLoadResponse) {
          result.fragment?.let {
            childFragmentManager.beginTransaction()
              .replace(R.id.chat_container, it, TAG)
              .commit()
          }
        }
      })
  }

  private fun getChatMX() {
    val deploymentId = "08685bd0-dbf1-42d4-bbf9-36e758310409"
    val domain = "usw2.pure.cloud"
    val account = MessengerAccount(deploymentId, domain).apply { logging = true }

    ChatController.Builder(requireContext())
      .build(account, object : ChatLoadedListener {
        override fun onComplete(result: ChatLoadResponse) {
          result.fragment?.let {
            childFragmentManager.beginTransaction()
              .replace(R.id.chat_container, it, TAG)
              .commit()
          }
        }
      })
  }
}

// 3. Factory for creating our Platform View
class ChatPlatformViewFactory(
  private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
    ChatPlatformView(context, messenger)
}

// 4. PlatformView that hosts ChatFragment
class ChatPlatformView(
  context: Context,
  messenger: BinaryMessenger
) : PlatformView, MethodCallHandler {

  private val container = FrameLayout(context).apply {
    id = View.generateViewId()
    layoutParams = FrameLayout.LayoutParams(
      FrameLayout.LayoutParams.MATCH_PARENT,
      FrameLayout.LayoutParams.MATCH_PARENT
    )
  }

  private val channel = MethodChannel(messenger, "com.trevor.app/kotlin").apply {
    setMethodCallHandler(this@ChatPlatformView)
  }

  init {
    // Load the US chat by default
    attachFragment(context, "US")
  }

  private fun attachFragment(ctx: Context, country: String) {
    (ctx as FragmentActivity).supportFragmentManager.beginTransaction()
      .replace(container.id, ChatFragment.newInstance(country), null)
      .commit()
  }

  override fun getView(): View = container
  override fun dispose() { channel.setMethodCallHandler(null) }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "getChatUS" -> {
        attachFragment(container.context, "US")
        result.success(null)
      }
      "getChatMX" -> {
        attachFragment(container.context, "MX")
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }
}