package com.pockeat

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

/**
 * Activity to display the rationale for Health Connect permissions.
 * This activity is launched when the user clicks the privacy policy link
 * in the Health Connect permissions screen.
 */
class PermissionsRationaleActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Create a simple layout programmatically
        setContentView(R.layout.activity_permissions_rationale)
        
        // Set up the close button
        val closeButton = findViewById<Button>(R.id.close_button)
        closeButton.setOnClickListener {
            finish()
        }
    }
}