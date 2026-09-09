import os
import re

lib_dir = r"d:\o2_clinic\lib"

image_network_pattern = re.compile(r'Image\.network\(([^,)]+)(.*?)\)', re.DOTALL)
network_image_pattern = re.compile(r'NetworkImage\(([^)]+)\)')

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    has_changes = False

    # Replace Image.network(url, ...) -> CachedImageWidget(imageUrl: url, ...)
    if 'Image.network' in content:
        content = image_network_pattern.sub(r'CachedImageWidget(imageUrl: \1\2)', content)
        if 'import \'package:o2_clinic/core/widgets/cached_image_widget.dart\';' not in content:
            # find first import and insert after
            match = re.search(r'import\s+[\'"].*?[\'"];\n', content)
            if match:
                content = content[:match.end()] + "import 'package:o2_clinic/core/widgets/cached_image_widget.dart';\n" + content[match.end():]
        has_changes = True

    # Replace NetworkImage(url) -> CachedNetworkImageProvider(url)
    if 'NetworkImage' in content:
        content = network_image_pattern.sub(r'CachedNetworkImageProvider(\1)', content)
        if 'import \'package:cached_network_image/cached_network_image.dart\';' not in content:
            match = re.search(r'import\s+[\'"].*?[\'"];\n', content)
            if match:
                content = content[:match.end()] + "import 'package:cached_network_image/cached_network_image.dart';\n" + content[match.end():]
        has_changes = True

    if original_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Done")
