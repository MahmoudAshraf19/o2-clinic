import json
import os

l10n_dir = r"d:\o2_clinic\o2_clinic\lib\l10n"
files = {
    "app_en.arb": {
        "doctorEmailNotFound": "This email is not found. Please contact administration.",
        "doctorEmailNotFoundTitle": "Email Not Found"
    },
    "app_ar.arb": {
        "doctorEmailNotFound": "هذا البريد الإلكتروني غير موجود، برجاء التواصل مع الإدارة.",
        "doctorEmailNotFoundTitle": "البريد غير موجود"
    },
    "app_he.arb": {
        "doctorEmailNotFound": "אימייל זה לא נמצא. אנא צור קשר עם ההנהלה.",
        "doctorEmailNotFoundTitle": "אימייל לא נמצא"
    }
}

for filename, new_strings in files.items():
    filepath = os.path.join(l10n_dir, filename)
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    data.update(new_strings)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        
print("Updated ARB files.")
