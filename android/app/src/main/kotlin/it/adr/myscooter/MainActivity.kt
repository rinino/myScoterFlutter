package it.adr.myscooter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import androidx.core.view.WindowCompat

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Questo comando comunica ad Android di far scorrere l'interfaccia
        // sotto le barre di sistema, eliminando i warning di deprecazione.
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}