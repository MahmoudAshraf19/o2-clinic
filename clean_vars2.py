import os
import subprocess

replacements = [
    (r'lib\features\auth\views\register_screen.dart', "final selected = controller.gender.value == value;", ''),
    (r'lib\features\booking\views\cosmetic_confirm_screen.dart', "final isAr = Get.locale?.languageCode == 'ar';", ''),
    (r'lib\features\booking\views\cosmetic_confirm_screen.dart', "final isAr = langCode == 'ar';", ''),
    (r'lib\features\booking\views\cosmetic_confirm_screen.dart', "final langCode = Get.locale?.languageCode ?? 'en';", ''),
    (r'lib\features\booking\views\xray_screen.dart', "final localeCode = Localizations.localeOf(context).languageCode;", ''),
    (r'lib\features\doctor_dashboard\views\doctor_booking_details_screen.dart', "this.icon,", ''),
    (r'lib\features\notifications\views\notifications_screen.dart', "final colors = _O2Colors(context);", ''),
    (r'lib\features\notifications\widgets\notification_dropdown_widget.dart', "Color _surfaceContainerLow(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : AppColors.surfaceContainerLow;", ''),
    (r'lib\features\notifications\widgets\notification_dropdown_widget.dart', "final String? avatarUrl;", ''),
    (r'lib\features\services\controllers\cosmetic_controller.dart', "import 'package:get/get.dart';", ''),
    (r'lib\features\splash\views\splash_screen.dart', "import 'package:o2_clinic/l10n/app_localizations.dart';", '')
]

for file_path, target, replacement in replacements:
    abs_path = os.path.join(r'd:\o2_clinic\o2_clinic', file_path)
    if os.path.exists(abs_path):
        with open(abs_path, 'r', encoding='utf-8') as f:
            content = f.read()
        if target in content:
            new_content = content.replace(target, replacement)
            with open(abs_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            subprocess.run(['git', 'add', file_path], cwd=r'd:\o2_clinic\o2_clinic')
            subprocess.run(['git', 'commit', '-m', f'Remove unused variable in {file_path}'], cwd=r'd:\o2_clinic\o2_clinic')
            print(f'Cleaned variable in {file_path}')
