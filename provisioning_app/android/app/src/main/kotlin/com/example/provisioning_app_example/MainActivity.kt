package com.example.provisioning_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Ensure the intent is set so Flutter/AppAuth can handle the deep link
        setIntent(intent)
    }
}
