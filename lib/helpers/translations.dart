import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'tasks': 'Tasks',
      'add_task': 'Add Task',
      'edit_task': 'Edit Task',
      'title': 'Title',
      'description': 'Description',
      'category': 'Category',
      'no_category': 'No Category',
      'add': 'Add',
      'save': 'Save',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'categories': 'Categories',
      'add_category': 'Add Category',
      'add_new_category': 'Add New Category',
      'edit_category': 'Edit Category',
      'name': 'Name',
      'color': 'Color',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'english': 'English',
      'arabic': 'العربية',
      'all': 'All',
      'completed': 'Completed',
      'pending': 'Pending',
      'no_tasks': 'No tasks yet',
      'no_categories': 'No categories yet',
      'delete_confirm': 'Are you sure?',
      'profile': 'Profile',
      'logout': 'Logout',
      'home': 'Home',
      'login': 'Login',
      'welcome_back': 'Welcome Back!',
      'login_subtitle': 'Please sign in to continue',
      'username': 'Username',
      'password': 'Password',
      'username_hint': 'Enter your username',
      'password_hint': 'Enter your password',
      'add_reminder': 'Add Reminder',
      'edit_reminder': 'Edit Reminder',
      'missed_reminder': 'Missed Reminder',
      'snooze_5m': 'Snooze 5 minutes',
      'snooze_10m': 'Snooze 10 minutes',
      'snooze_30m': 'Snooze 30 minutes',
      'snooze_1h': 'Snooze 1 hour',
      'cancel_reminder': 'Cancel reminder',
      'snoozed': 'Snoozed',
      'reminder_cancelled': 'Reminder cancelled',
      'in_minutes': 'in @minutes minutes',
      'in_hours': 'in @hours hours',
      'after': 'after',
    },
    'ar_SA': {
      'tasks': 'المهام',
      'add_task': 'إضافة مهمة',
      'edit_task': 'تعديل المهمة',
      'title': 'العنوان',
      'description': 'الوصف',
      'category': 'الفئة',
      'no_category': 'بدون فئة',
      'add': 'إضافة',
      'save': 'حفظ',
      'delete': 'حذف',
      'cancel': 'إلغاء',
      'edit': 'تعديل',
      'categories': 'الفئات',
      'add_category': 'إضافة فئة',
      'add_new_category': 'إضافة فئة جديدة',
      'edit_category': 'تعديل الفئة',
      'name': 'الاسم',
      'color': 'اللون',
      'settings': 'الإعدادات',
      'theme': 'المظهر',
      'language': 'اللغة',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'english': 'English',
      'arabic': 'العربية',
      'all': 'الكل',
      'completed': 'مكتمل',
      'pending': 'معلق',
      'no_tasks': 'لا توجد مهام',
      'no_categories': 'لا توجد فئات',
      'delete_confirm': 'هل أنت متأكد؟',
      'profile': 'الملف الشخصي',
      'logout': 'تسجيل الخروج',
      'home': 'الرئيسية',
      'login': 'تسجيل الدخول',
      'welcome_back': 'أهلاً بك مجدداً!',
      'login_subtitle': 'يرجى تسجيل الدخول للمتابعة',
      'username': 'اسم المستخدم',
      'password': 'كلمة المرور',
      'username_hint': 'أدخل اسم المستخدم',
      'password_hint': 'أدخل كلمة المرور',
      'add_reminder': 'إضافة تذكير',
      'edit_reminder': 'تعديل تذكير',
      'missed_reminder': 'تذكير غائب',
      'snooze_5m': 'تأجيل 5 دقائق',
      'snooze_10m': 'تأجيل 10 دقائق',
      'snooze_30m': 'تأجيل 30 دقيقة',
      'snooze_1h': 'تأجيل ساعة',
      'cancel_reminder': 'إلغاء التذكير',
      'snoozed': 'تم التأجيل',
      'reminder_cancelled': 'تم إلغاء التذكير',
      'in_minutes': 'بعد @minutes دقائق',
      'in_hours': 'بعد @hours ساعات',
      'after': 'بعد',
    },
  };

  /// Localizes numbers (e.g., 123 -> ١٢٣ in Arabic)
  static String localizeNumber(num value) {
    final String locale = Get.locale?.languageCode ?? 'en';
    return NumberFormat.decimalPattern(locale).format(value);
  }

  /// Returns a human-readable relative time string
  static String localizedRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final locale = Get.locale?.languageCode ?? 'en';

    // 1. Handle Future or very recent dates
    if (difference.isNegative || difference.inSeconds < 45) {
      return locale == 'ar' ? 'الآن' : 'Just now';
    }

    // 2. Handle Minutes
    if (difference.inMinutes < 60) {
      return _pluralize(difference.inMinutes, 'minute', locale);
    }

    // 3. Handle Hours
    if (difference.inHours < 24) {
      return _pluralize(difference.inHours, 'hour', locale);
    }

    // 4. Handle Days
    return _pluralize(difference.inDays, 'day', locale);
  }

  static String localizedDuration(Duration duration) {
    final locale = Get.locale?.languageCode ?? 'en';
    final minutes = duration.inMinutes;
    final hours = duration.inHours;

    if (minutes < 60) {
      return _pluralize(minutes, 'minute', locale, isRelative: false);
    } else {
      return _pluralize(hours, 'hour', locale, isRelative: false);
    }
  }

  /// Private helper to handle complex plural rules using Intl.plural
  static String _pluralize(
    int count,
    String unit,
    String locale, {
    bool isRelative = true,
  }) {
    final String formattedCount = localizeNumber(count);
    final String prefix = (locale == 'ar' && isRelative) ? 'منذ ' : '';
    final String suffix = (locale == 'en' && isRelative) ? ' ago' : '';

    if (locale == 'ar') {
      if (unit == 'minute') {
        return Intl.plural(
          count,
          one: '$prefixدقيقة',
          two: '$prefixدقيقتين',
          few: '$prefix$formattedCount دقائق',
          many: '$prefix$formattedCount دقيقة',
          other: '$prefix$formattedCount دقيقة',
          locale: 'ar',
        );
      } else if (unit == 'hour') {
        return Intl.plural(
          count,
          one: 'منذ ساعة',
          two: 'منذ ساعتين',
          few: 'منذ $formattedCount ساعات',
          many: 'منذ $formattedCount ساعة',
          other: 'منذ $formattedCount ساعة',
          locale: 'ar',
        );
      } else {
        return Intl.plural(
          count,
          one: 'منذ يوم',
          two: 'منذ يومين',
          few: 'منذ $formattedCount أيام',
          many: 'منذ $formattedCount يوم',
          other: 'منذ $formattedCount يوم',
          locale: 'ar',
        );
      }
    }

    // English
    return Intl.plural(
      count,
      one: '1 $unit$suffix',
      other: '$formattedCount ${unit}s$suffix',
      locale: 'en',
    );
  }
}
