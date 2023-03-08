package uk.co.tdsstudios.noterly

import io.flutter.embedding.android.FlutterActivity

// new for sharing
import android.os.Bundle
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
// end

class MainActivity: FlutterActivity() {
    // new for sharing
    override fun onCreate(savedInstanceState: Bundle?) {
        if (intent.getIntExtra("org.chromium.chrome.extra.TASK_ID", -1) == this.taskId) {
            this.finish()
            intent.addFlags(FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        }
        super.onCreate(savedInstanceState)
    }
    //end
}
