import os
import re

lib_dir = r'd:\o2_clinic\o2_clinic\lib'

# Find AppColors.xxx.shadeYYY -> AppColors.xxxYYY
shade_regex = re.compile(r'AppColors\.([a-zA-Z0-9_]+)\.shade([0-9]+)')
# Find AppColors.xxx[YYY] -> AppColors.xxxYYY
index_regex = re.compile(r'AppColors\.([a-zA-Z0-9_]+)\[([0-9]+)\]')

count = 0
for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            def repl(match):
                color = match.group(1)
                shade = match.group(2)
                return f'AppColors.{color}{shade}'
                
            content = shade_regex.sub(repl, content)
            content = index_regex.sub(repl, content)
            
            if content != original_content:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(content)
                count += 1

print(f'Fixed {count} files with shade/index errors.')
