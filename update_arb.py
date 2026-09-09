import json
import os

l10n_dir = r"d:\o2_clinic\o2_clinic\lib\l10n"
files = {
    "app_en.arb": {
        "loginAsDoctor": "Login as Doctor",
        "doctorLogin": "Doctor Login",
        "welcomeBackDoctor": "Welcome back, Doctor. Please login to continue.",
        "doctorHome": "Home",
        "doctorAppointments": "Appts",
        "doctorPatients": "Patients",
        "doctorChats": "Chats",
        "doctorProfile": "Profile"
    },
    "app_ar.arb": {
        "loginAsDoctor": "تسجيل دخول كطبيب",
        "doctorLogin": "تسجيل دخول الطبيب",
        "welcomeBackDoctor": "مرحباً بك مجدداً دكتور. يرجى تسجيل الدخول للمتابعة.",
        "doctorHome": "الرئيسية",
        "doctorAppointments": "المواعيد",
        "doctorPatients": "المرضى",
        "doctorChats": "المحادثات",
        "doctorProfile": "حسابي"
    },
    "app_he.arb": {
        "loginAsDoctor": "התחבר כרופא",
        "doctorLogin": "כניסת רופא",
        "welcomeBackDoctor": "ברוך שובך, דוקטור. אנא התחבר כדי להמשיך.",
        "doctorHome": "ראשי",
        "doctorAppointments": "תורים",
        "doctorPatients": "מטופלים",
        "doctorChats": "צ'אטים",
        "doctorProfile": "פרופיל"
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
