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
                
                # AppLocalizations as l10n
                new_content = re.sub(r'(l10n\.[a-zA-Z0-9_]+)\s*\?\?\s*([\'"][^\'"]*[\'"])', r'\1', new_content)
                
                # doctor_app_bar.dart isGuest
                if file == 'doctor_app_bar.dart':
                    new_content = re.sub(r'final isGuest = false;.*', 'final isGuest = false;', new_content)
                    new_content = re.sub(r'if\s*\(\s*isGuest\s*\)\s*...\[.*?\]\,', '', new_content, flags=re.DOTALL)
                    new_content = re.sub(r'isGuest\s*\?\s*.*?:\s*', '', new_content)
                    new_content = re.sub(r'isGuest\s*\|\|', '', new_content)
                    
                # next_patient_widget.dart doctor.nameEn
                if file == 'next_patient_widget.dart':
                    new_content = re.sub(r'doctor\.nameEn\s*\?\?\s*([\'"][^\'"]*[\'"])', 'doctor.nameEn', new_content)
                    
                # past_appointments_widget.dart doctorName
                if file == 'past_appointments_widget.dart':
                    new_content = re.sub(r'doctor\.nameEn\s*\?\?\s*([\'"][^\'"]*[\'"])', 'doctor.nameEn', new_content)

                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Fixed warnings in {filepath}")

fix_warnings(r'd:\o2_clinic\o2_clinic\lib')
