import json
import re

log_path = r'C:\Users\mashr\.gemini\antigravity-ide\brain\9b1cda88-0295-4c6b-8e36-5e0f0dd87d8c\.system_generated\logs\transcript.jsonl'
output_path = r'd:\o2_clinic\lib\features\booking\views\cosmetic_booking_page.dart'

content_lines = {}
found = False
with open(log_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            data = json.loads(line)
            # Find the view_file response
            if 'response' in data and 'output' in data['response']:
                out = data['response']['output']
                if 'cosmetic_booking_page.dart' in out and 'Showing lines 1 to 428' in out:
                    found = True
                    lines = out.split('\n')
                    for l in lines:
                        match = re.match(r'^(\d+):\s(.*)$', l)
                        if match:
                            line_num = int(match.group(1))
                            line_content = match.group(2)
                            content_lines[line_num] = line_content
        except:
            pass

if content_lines:
    max_line = max(content_lines.keys())
    with open(output_path, 'w', encoding='utf-8') as f:
        for i in range(1, max_line + 1):
            f.write(content_lines.get(i, '') + '\n')
    print(f"Recovered {max_line} lines")
else:
    print(f"Failed to recover. found={found}")
