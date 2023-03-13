package uk.co.tdsstudios.noterly

import android.annotation.TargetApi
import android.content.Intent
import android.os.Build
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
import io.flutter.Log

@TargetApi(Build.VERSION_CODES.N)
@RequiresApi(Build.VERSION_CODES.N)
class MyTileService : TileService() {
    override fun onClick() {
        super.onClick()

        try {
//            val newIntent = FlutterActivity.withNewEngine().dartEntrypointArgs(listOf("launchFromQuickTile")).build(this)

//            val newIntent = Intent(this, MainActivity::class.java)

            val newIntent = Intent(
                "uk.co.tdsstudios.noterly.ACTION_CREATE_NOTE",
                null,
                this,
                MainActivity::class.java
            )


            newIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivityAndCollapse(newIntent)
        } catch (e: Exception) {
            Log.d("debug", "Exception ${e.toString()}")
        }
    }
}