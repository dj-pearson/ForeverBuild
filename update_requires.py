import os
import re

# Map old patterns to new patterns
REQUIRE_PATTERNS = [
    # Shared modules
    (re.compile(r'require\s*\(\s*game\.ReplicatedStorage\.shared\.([A-Za-z0-9_]+)\s*\)'), r'require(game.ReplicatedStorage.Shared.\1)'),
    (re.compile(r'require\s*\(\s*game\.ReplicatedStorage\.Modules\.([A-Za-z0-9_]+)\s*\)'), r'require(game.ReplicatedStorage.Modules.\1)'),
    # Server modules
    (re.compile(r'require\s*\(\s*game\.ServerScriptService\.server\.Modules\.([A-Za-z0-9_]+)\s*\)'), r'require(game.ServerScriptService.Modules.\1)'),
    (re.compile(r'require\s*\(\s*game\.ServerScriptService\.server\.([A-Za-z0-9_]+)\s*\)'), r'require(game.ServerScriptService.\1)'),
    # Client modules
    (re.compile(r'require\s*\(\s*game\.StarterPlayer\.client\.Modules\.([A-Za-z0-9_]+)\s*\)'), r'require(game.StarterPlayer.StarterPlayerScripts.Modules.\1)'),
    (re.compile(r'require\s*\(\s*game\.StarterPlayer\.client\.([A-Za-z0-9_]+)\s*\)'), r'require(game.StarterPlayer.StarterPlayerScripts.\1)'),
    # Folder root (init)
    (re.compile(r'require\s*\(\s*game\.ServerScriptService\.server\.Modules\s*\)'), r'require(game.ServerScriptService.Modules)'),
    (re.compile(r'require\s*\(\s*game\.StarterPlayer\.client\.Modules\s*\)'), r'require(game.StarterPlayer.StarterPlayerScripts.Modules)'),
    (re.compile(r'require\s*\(\s*game\.ReplicatedStorage\.shared\.Modules\s*\)'), r'require(game.ReplicatedStorage.Modules)'),
    (re.compile(r'require\s*\(\s*game\.ReplicatedStorage\.shared\s*\)'), r'require(game.ReplicatedStorage.Shared)'),
]

def update_requires_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content
    for pattern, replacement in REQUIRE_PATTERNS:
        content = pattern.sub(replacement, content)
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {filepath}")

def walk_and_update(root):
    for dirpath, _, filenames in os.walk(root):
        for filename in filenames:
            if filename.endswith('.luau') or filename.endswith('.lua'):
                update_requires_in_file(os.path.join(dirpath, filename))

if __name__ == "__main__":
    # Change this to your project root if needed
    walk_and_update("src")