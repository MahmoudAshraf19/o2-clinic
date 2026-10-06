import os
import subprocess

replacements = [
    (r'lib\common\widgets\common_button.dart', 'final buttonStyle = _getButtonStyle();', ''),
    (r'lib\core\utils\media_compressor.dart', "final targetPath =\n          '${tempDir.path}${Platform.pathSeparator}COMP_${DateTime.now().millisecondsSinceEpoch}.jpg';", ''),
    (r'lib\core\utils\web_helper_web.dart', "final anchor = html.AnchorElement(href: url)\n    ..setAttribute('download', fileName)", ''),
    (r'lib\core\widgets\app_bar\o2_app_bar.dart', "static const _subtitle = 'Your health comes first';", ''),
    (r'lib\features\appointments\presentation\screens\my_appointments_screen.dart', "final now = DateTime.now();", ''),
    (r'lib\features\doctor_dashboard\widgets\doctor_app_bar.dart', "static const _subtitle = 'Your health comes first';", ''),
    (r'lib\features\notifications\controllers\notifications_controller.dart', "final seenBookingIds = <String>{};", ''),
    (r'lib\features\notifications\views\notifications_screen.dart', "final colors = _O2Colors(context);", ''),
    (r'lib\features\services\controllers\cosmetic_controller.dart', "final localeCode = Localizations.localeOf(Get.context!).languageCode;", ''),
    (r'lib\features\splash\views\splash_screen.dart', "final l10n = AppLocalizations.of(context)!;", '')
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
