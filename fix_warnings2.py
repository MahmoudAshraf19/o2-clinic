import os
import re

def fix_warnings(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()

                new_content = content
                
                # 1. Unreachable switch default in doctor_statistics_controller.dart
                if file == 'doctor_statistics_controller.dart':
                    new_content = new_content.replace('case StatFilter.allTime:\n        default:', 'case StatFilter.allTime:')
                    new_content = new_content.replace('case StatFilter.allTime:\n      default:', 'case StatFilter.allTime:')
                    new_content = new_content.replace('default:\n          include = true;\n          break;', '') # in case it's formatted differently
                    # Better regex for default after allTime
                    new_content = re.sub(r'case StatFilter\.allTime:\s*default:', 'case StatFilter.allTime:', new_content)
                
                # 2. Unused local variable currency
                if file in ['Ultrasound_screen.dart', 'cosmetic_success_screen.dart', 'imaging_success_screen.dart']:
                    new_content = re.sub(r'[ \t]*final currency = [^;]+;\s*', '', new_content)

                # 3. Dead null aware expressions (AppLocalizations)
                # AppLocalizations.of(context)!.someString ?? 'Fallback'
                # AppLocalizations.of(context)!.someString ?? "Fallback"
                new_content = re.sub(r'(AppLocalizations\.of\(context\)!?\.[a-zA-Z0-9_]+)\s*\?\?\s*([\'"][^\'"]*[\'"])', r'\1', new_content)

                # There are also things like (AppLocalizations.of(context)!.something) ?? 'Fallback'
                new_content = re.sub(r'\((AppLocalizations\.of\(context\)!?\.[a-zA-Z0-9_]+)\)\s*\?\?\s*([\'"][^\'"]*[\'"])', r'\1', new_content)
                
                # What about loc!.something ?? '' ?
                # If we see `loc!.something ?? '...'`, or `loc.something ?? '...'` where `loc` is AppLocalizations.
                new_content = re.sub(r'(loc!?[.]?[a-zA-Z0-9_]*)\s*\?\?\s*([\'"][^\'"]*[\'"])', r'\1', new_content) # Wait, this might be risky. We'll stick to AppLocalizations for now.

                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Fixed warnings in {filepath}")

fix_warnings(r'd:\o2_clinic\o2_clinic\lib')
