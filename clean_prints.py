import os
import re

def clean_prints(directory):
    print_pattern = re.compile(r'^\s*print\s*\(.*?\)\s*;\s*$', re.MULTILINE | re.DOTALL)
    # A simpler approach: process line by line, if a line has print(...) and ends with ;, we remove it.
    # If it spans multiple lines, we might miss it with line-by-line, so we read the whole file.

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()

                # Remove print statements like: print('...');
                # This regex handles basic prints, even spanning a few lines, assuming no complex nested parenthesis if we are careful.
                # Actually, an easier regex for single-statement print:
                new_content = re.sub(r'^[ \t]*print\s*\([^;]*\);\s*?\n', '', content, flags=re.MULTILINE)
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Cleaned prints in {filepath}")

clean_prints(r'd:\o2_clinic\o2_clinic\lib')
