import os
import re

def fix_syntax(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()

                # 1. Remove unnecessary typed_data imports
                new_content = re.sub(r"import 'dart:typed_data';\n?", "", content)
                new_content = re.sub(r"import 'dart:ui';\n?", "", new_content)

                # 2. Fix withOpacity -> withValues(alpha: ...)
                # Regex matches .withOpacity(value)
                new_content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', new_content)

                # 3. Fix multiple underscores __ -> _
                # We only want to replace multiple underscores used as variable names or in names.
                # Actually, dart analyze output said: Unnecessary use of multiple underscores
                # This often happens when people do `__` for unused parameters in closures.
                new_content = re.sub(r'\b__\b', '_', new_content)

                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Fixed syntax in {filepath}")

fix_syntax(r'd:\o2_clinic\o2_clinic\lib')
