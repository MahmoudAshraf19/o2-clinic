import os
import subprocess

file_path = r'd:\o2_clinic\o2_clinic\lib\features\notifications\widgets\notification_dropdown_widget.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if '_surfaceContainerLow' in line or 'this.avatarUrl,' in line:
        continue
    new_lines.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

subprocess.run(['git', 'add', file_path], cwd=r'd:\o2_clinic\o2_clinic')
subprocess.run(['git', 'commit', '-m', 'Remove unused fields in notification_dropdown_widget'], cwd=r'd:\o2_clinic\o2_clinic')
print('Done cleaning notification_dropdown_widget')
