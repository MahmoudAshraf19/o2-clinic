import os
import re

lib_dir = r'd:\o2_clinic\o2_clinic\lib'
app_colors_path = r'd:\o2_clinic\o2_clinic\lib\core\theme\app_colors.dart'

# Step 1: Read existing app_colors.dart to find existing names
with open(app_colors_path, 'r', encoding='utf-8') as f:
    app_colors_content = f.read()

existing_hex_to_name = {}
hex_def_regex = re.compile(r'static\s+const\s+Color\s+([a-zA-Z0-9_]+)\s*=\s*Color\(\s*0[xX]([0-9a-fA-F]{8})\s*\)')
for match in hex_def_regex.finditer(app_colors_content):
    name = match.group(1)
    hex_val = match.group(2).upper()
    existing_hex_to_name[hex_val] = name

existing_material_colors = set()
material_def_regex = re.compile(r'static\s+const\s+Color\s+([a-zA-Z0-9_]+)\s*=\s*Colors\.([a-zA-Z0-9_]+)')
for match in material_def_regex.finditer(app_colors_content):
    name = match.group(1)
    existing_material_colors.add(name)

assignment_regex = re.compile(r'static\s+const\s+Color\s+([a-zA-Z0-9_]+)\s*=\s*([a-zA-Z0-9_]+)')
for match in assignment_regex.finditer(app_colors_content):
    existing_material_colors.add(match.group(1))

hex_color_regex = re.compile(r'Color\(\s*0[xX]([0-9a-fA-F]{8})\s*\)')
material_color_regex = re.compile(r'(?<!App)(?<!\w)Colors\.([a-zA-Z][a-zA-Z0-9_]*)')

all_hex = set()
all_material = set()

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart') and file != 'app_colors.dart':
            with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                content = f.read()
                all_hex.update(m.group(1).upper() for m in hex_color_regex.finditer(content))
                all_material.update(m.group(1) for m in material_color_regex.finditer(content))

new_hex_definitions = []
for h in sorted(list(all_hex)):
    if h not in existing_hex_to_name:
        name = f'color{h}'
        existing_hex_to_name[h] = name
        new_hex_definitions.append(f'  static const Color {name} = Color(0x{h});')

new_material_definitions = []
for m in sorted(list(all_material)):
    if m not in existing_material_colors and m not in existing_hex_to_name.values():
        new_material_definitions.append(f'  static const Color {m} = Colors.{m};')

if new_hex_definitions or new_material_definitions:
    last_brace_index = app_colors_content.rfind('}')
    insertion = '\n  // --- Auto-generated colors ---\n'
    if new_material_definitions:
        insertion += '\n'.join(new_material_definitions) + '\n'
    if new_hex_definitions:
        insertion += '\n'.join(new_hex_definitions) + '\n'
    
    app_colors_content = app_colors_content[:last_brace_index] + insertion + app_colors_content[last_brace_index:]
    with open(app_colors_path, 'w', encoding='utf-8') as f:
        f.write(app_colors_content)
    print(f'Added {len(new_hex_definitions)} hex colors and {len(new_material_definitions)} material colors to app_colors.dart')

import_statement = "import 'package:o2_clinic/core/theme/app_colors.dart';"
modified_count = 0
for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart') and file != 'app_colors.dart' and file != 'app_theme.dart':
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            def hex_repl(match):
                h = match.group(1).upper()
                return 'AppColors.' + existing_hex_to_name[h]
            content = hex_color_regex.sub(hex_repl, content)
            
            def mat_repl(match):
                m = match.group(1)
                return 'AppColors.' + m
            content = material_color_regex.sub(mat_repl, content)
            
            if content != original_content:
                if 'app_colors.dart' not in content:
                    last_import_index = content.rfind('import ')
                    if last_import_index != -1:
                        end_of_line = content.find(';', last_import_index)
                        if end_of_line != -1:
                            content = content[:end_of_line+1] + '\n' + import_statement + content[end_of_line+1:]
                        else:
                            content = import_statement + '\n' + content
                    else:
                        content = import_statement + '\n' + content
                
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(content)
                modified_count += 1

print(f'Modified {modified_count} files.')
