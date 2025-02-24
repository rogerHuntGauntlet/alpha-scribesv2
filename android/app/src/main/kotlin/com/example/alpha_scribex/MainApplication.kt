package com.example.alpha_scribex

import io.flutter.app.FlutterApplication

class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        // Disable deferred components
        System.setProperty("flutter.deferred.components.enabled", "false")
    }
} 