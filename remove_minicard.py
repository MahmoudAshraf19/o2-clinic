import os
import subprocess

file_path = r'd:\o2_clinic\o2_clinic\lib\features\profile\view\settings_screen.dart'
start_line = 298
end_line = 377

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = lines[:start_line-1] + lines[end_line:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

subprocess.run(['git', 'add', file_path], cwd=r'd:\o2_clinic\o2_clinic')
subprocess.run(['git', 'commit', '-m', 'Remove unused _MiniCard class'], cwd=r'd:\o2_clinic\o2_clinic')
print('Removed _MiniCard')
