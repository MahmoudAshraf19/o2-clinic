import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

class NotificationTimeHelper {
  /// Returns a localized relative time string (e.g. "Just now", "3m ago", "Yesterday").
  /// Pass [context] from a widget build method to get localizations.
  static String getRelativeTime(DateTime dateTime, {BuildContext? context}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (context != null) {
      final l = AppLocalizations.of(context);
      if (l != null) {
        if (difference.inSeconds < 60) return l.notifTimeJustNow;
        if (difference.inMinutes < 60) return l.notifTimeMinutesAgo(difference.inMinutes);
        if (difference.inHours < 24) return l.notifTimeHoursAgo(difference.inHours);
        if (difference.inDays == 1 && now.day != dateTime.day) return l.notifTimeYesterday;
        if (difference.inDays < 7) return l.notifTimeDaysAgo(difference.inDays);
      }
    }

    // Fallback (no context available)
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1 && now.day != dateTime.day) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return DateFormat('MMM d').format(dateTime);
  }

  /// Returns a localized full date/time string (e.g. "Yesterday at 3:00 PM", "Jul 5, 3:00 PM").
  static String getFullDateTime(DateTime dateTime, {BuildContext? context}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (context != null) {
      final l = AppLocalizations.of(context);
      if (l != null && difference.inDays >= 1 && now.day != dateTime.day && difference.inDays < 2) {
        // "Yesterday at HH:mm"
        return '${l.notifTimeYesterday} ${DateFormat('h:mm a').format(dateTime)}';
      }
    }

    return DateFormat('MMM d, h:mm a').format(dateTime);
  }
}
