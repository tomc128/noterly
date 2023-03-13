package uk.co.tdsstudios.noterly

import android.annotation.TargetApi
import android.content.Intent
import android.os.Build
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity

@TargetApi(Build.VERSION_CODES.N)
@RequiresApi(Build.VERSION_CODES.N)
class MyTileService : TileService() {
    override fun onClick() {
        super.onClick()

        try {
            val newIntent = FlutterActivity.withNewEngine().dartEntrypointArgs(listOf("launchFromQuickTile")).build(this)
            newIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivityAndCollapse(newIntent)
        } catch (e: Exception) {
            Log.d("debug", "Exception ${e.toString()}")
        }
    }

    override fun onTileRemoved() {
        super.onTileRemoved()
        // Do something when the user removes the Tile
    }

    override fun onTileAdded() {
        super.onTileAdded()

        // Do something when the user add the Tile
    }

    override fun onStartListening() {
        super.onStartListening()

        // Called when the Tile becomes visible
    }

    override fun onStopListening() {
        super.onStopListening()

        // Called when the tile is no longer visible
    }


}