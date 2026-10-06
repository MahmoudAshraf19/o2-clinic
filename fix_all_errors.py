import os
import re

ui_files = [
    r'lib\core\navigation\widgets\app_bottom_navigation_bar.dart',
    r'lib\features\booking\presentation\pages\booking_page.dart',
    r'lib\features\booking\views\imaging_booking_page.dart',
    r'lib\features\booking\widgets\service_card.dart',
    r'lib\features\contact_us\presentation\screens\our_location_screen.dart',
    r'lib\features\doctor_dashboard\widgets\doctor_bottom_navigation_bar.dart',
    r'lib\features\doctors\widgets\doctor_card.dart',
    r'lib\features\onboarding\widgets\onboarding_background.dart',
    r'lib\features\services\widgets\cosmetic_cards.dart',
    r'lib\features\services\widgets\radiology_card_item.dart'
]

typed_data_files = [
    r'lib\core\utils\web_helper_stub.dart',
    r'lib\features\doctor_dashboard\controllers\doctor_edit_profile_controller.dart'
]

for file in ui_files:
    if os.path.exists(file):
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
        if "import 'dart:ui';" not in content:
            content = "import 'dart:ui';\n" + content
            with open(file, 'w', encoding='utf-8') as f:
                f.write(content)

for file in typed_data_files:
    if os.path.exists(file):
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
        if "import 'dart:typed_data';" not in content:
            content = "import 'dart:typed_data';\n" + content
            with open(file, 'w', encoding='utf-8') as f:
                f.write(content)

# web_helper_web.dart
web_helper = r'lib\core\utils\web_helper_web.dart'
if os.path.exists(web_helper):
    with open(web_helper, 'w', encoding='utf-8') as f:
        f.write('''import 'dart:html' as html;
import 'dart:typed_data';

void downloadFileWeb(Uint8List bytes, String fileName) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
''')

# doctor_booking_details_screen.dart
doc_booking = r'lib\features\doctor_dashboard\views\doctor_booking_details_screen.dart'
if os.path.exists(doc_booking):
    with open(doc_booking, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("required \n    required this.title,", "required this.icon,\n    required this.title,")
    content = content.replace("required this.onTap,\n    \n  });", "required this.onTap,\n    this.icon,\n  });")
    with open(doc_booking, 'w', encoding='utf-8') as f:
        f.write(content)

# notifications_screen.dart
notif_screen = r'lib\features\notifications\views\notifications_screen.dart'
if os.path.exists(notif_screen):
    with open(notif_screen, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("colors.onSurface", "_colors.onSurface")
    with open(notif_screen, 'w', encoding='utf-8') as f:
        f.write(content)

# notification_dropdown_widget.dart
notif_dropdown = r'lib\features\notifications\widgets\notification_dropdown_widget.dart'
if os.path.exists(notif_dropdown):
    with open(notif_dropdown, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("required this.showTopDivider,\n  });", "required this.showTopDivider,\n    this.avatarUrl,\n  });")
    content = content.replace("final bool showTopDivider;\n  \n", "final bool showTopDivider;\n  final String? avatarUrl;\n")
    with open(notif_dropdown, 'w', encoding='utf-8') as f:
        f.write(content)

# cosmetic_confirm_screen.dart
cosmetic_confirm = r'lib\features\booking\views\cosmetic_confirm_screen.dart'
if os.path.exists(cosmetic_confirm):
    with open(cosmetic_confirm, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("CircleAvatar(\n            radius: 26,", "Builder(builder: (context) {\n          final langCode = Get.locale?.languageCode ?? 'en';\n          return Row(\n            children: [\n              CircleAvatar(\n            radius: 26,")
    content = content.replace("style: TextStyle(color: AppColors.grey, fontSize: 13),\n                ),\n              ],\n            ),\n          ),\n        ],\n      ),\n    );", "style: TextStyle(color: AppColors.grey, fontSize: 13),\n                ),\n              ],\n            ),\n          ),\n            ],\n          );\n        }),\n      ),\n    );")
    with open(cosmetic_confirm, 'w', encoding='utf-8') as f:
        f.write(content)

# my_appointments_screen.dart
my_appts = r'lib\features\appointments\presentation\screens\my_appointments_screen.dart'
if os.path.exists(my_appts):
    with open(my_appts, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("final diffDays = now.difference(date).inDays;", "final now = DateTime.now();\n    final diffDays = now.difference(date).inDays;")
    with open(my_appts, 'w', encoding='utf-8') as f:
        f.write(content)

# dashboard_pending_action_bookings.dart
dashboard_pending = r'lib\features\dashboard\widgets\dashboard_pending_action_bookings.dart'
if os.path.exists(dashboard_pending):
    with open(dashboard_pending, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace("foregroundcolor:", "foregroundColor:")
    with open(dashboard_pending, 'w', encoding='utf-8') as f:
        f.write(content)
