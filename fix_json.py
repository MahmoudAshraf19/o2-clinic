import json
import os

file_path = r'd:\o2_clinic\doctors_trilingual_ar_en_he.json'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

def fix_availability(obj):
    if isinstance(obj, dict):
        if 'availability_day' in obj:
            avail = obj['availability_day']
            if isinstance(avail, dict):
                for day, val in avail.items():
                    if isinstance(val, dict):
                        # Extract the time string
                        time_str = val.get('en') or val.get('ar') or val.get('he')
                        if not time_str and len(val) > 0:
                            time_str = list(val.values())[0]
                        if time_str:
                            avail[day] = time_str
        # Recursively check other dictionary values
        for k, v in obj.items():
            fix_availability(v)
    elif isinstance(obj, list):
        for item in obj:
            fix_availability(item)

fix_availability(data)

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("✅ Updated availability_day format successfully.")
