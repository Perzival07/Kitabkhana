package com.kitabkhana.kitabkhana

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews

/**
 * "Currently reading" on the home screen: the book, its page and progress,
 * and loans. The app writes the text (already in the reader's language) to
 * private SharedPreferences through [CHANNEL]; the widget only shows it and
 * opens the app when tapped. No network, no extra permissions.
 */
class ReadingWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) manager.updateAppWidget(id, views(context))
    }

    companion object {
        const val CHANNEL = "kitabkhana/widget"
        private const val PREFS = "kitabkhana_widget"

        fun save(context: Context, data: Map<String, Any?>) {
            val edit = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            for (key in listOf("label", "title", "subtitle", "footer")) {
                edit.putString(key, data[key] as? String ?: "")
            }
            edit.putInt("progress", (data["progress"] as? Number)?.toInt() ?: -1)
            edit.apply()
        }

        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, ReadingWidgetProvider::class.java))
            for (id in ids) manager.updateAppWidget(id, views(context))
        }

        private fun views(context: Context): RemoteViews {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.reading_widget)
            val label = prefs.getString("label", "") ?: ""
            val title = prefs.getString("title", "") ?: ""
            views.setTextViewText(
                R.id.widget_label,
                if (label.isEmpty()) context.getString(R.string.widget_label) else label,
            )
            views.setTextViewText(
                R.id.widget_title,
                if (title.isEmpty()) context.getString(R.string.widget_empty) else title,
            )
            views.setTextViewText(R.id.widget_subtitle, prefs.getString("subtitle", "") ?: "")
            views.setTextViewText(R.id.widget_footer, prefs.getString("footer", "") ?: "")
            val progress = prefs.getInt("progress", -1)
            if (progress in 0..100) {
                views.setViewVisibility(R.id.widget_progress, View.VISIBLE)
                views.setProgressBar(R.id.widget_progress, 100, progress, false)
            } else {
                views.setViewVisibility(R.id.widget_progress, View.GONE)
            }
            val open = Intent(context, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            val pending = PendingIntent.getActivity(
                context,
                0,
                open,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pending)
            return views
        }
    }
}
