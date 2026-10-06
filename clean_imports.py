import re
import os
import subprocess

log_file = r'C:\Users\mashr\.gemini\antigravity-ide\brain\7249a737-ba3a-4063-ae8e-a509ae6c5ac6\.system_generated\tasks\task-7.log'

with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

# Collect unused imports
unused_imports = {} # file_path -> list of line numbers

for line in lines:
    if 'unused_import' in line and 'warning -' in line:
        parts = line.split(' - ')
        if len(parts) >= 3:
            location_part = parts[-2]
            match = re.search(r'(.*):(\d+):\d+$', location_part)
            if match:
                file_path = match.group(1).strip()
                line_num = int(match.group(2))
                
                if file_path not in unused_imports:
                    unused_imports[file_path] = []
                unused_imports[file_path].append(line_num)

for file_path, line_nums in unused_imports.items():
    abs_path = os.path.join(r'd:\o2_clinic\o2_clinic', file_path)
    if os.path.exists(abs_path):
        with open(abs_path, 'r', encoding='utf-8') as f:
            content = f.readlines()
        
        # Sort in reverse to delete without affecting subsequent line numbers
        for ln in sorted(list(set(line_nums)), reverse=True):
            idx = ln - 1
            if 0 <= idx < len(content):
                del content[idx]
        
        with open(abs_path, 'w', encoding='utf-8') as f:
            f.writelines(content)
        
        # Git commit
        subprocess.run(['git', 'add', file_path], cwd=r'd:\o2_clinic\o2_clinic')
        subprocess.run(['git', 'commit', '-m', f'Remove unused imports in {file_path}'], cwd=r'd:\o2_clinic\o2_clinic')
        print(f'Cleaned and committed {file_path}')
