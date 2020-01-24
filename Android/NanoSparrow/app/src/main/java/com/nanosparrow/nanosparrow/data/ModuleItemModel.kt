package com.nanosparrow.nanosparrow.data

import android.app.Activity
import android.graphics.drawable.Drawable

data class ModuleItemModel (
    val moduleName: String,
    val moduleImage: Drawable,
    val activityClass: Class<Activity>
    ) {

}