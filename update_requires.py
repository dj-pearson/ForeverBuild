import os
import re

# Patterns to match and their replacements
REQUIRE_PATTERNS = [
    # Global patterns (old to new)
    (re.compile(r'require\s*\(\s*game\.ReplicatedStorage\.shared\.([A-Za-z0-9_]+)\s*\)'), r'require(game.ReplicatedStorage.Shared.\1)'),
    (re.compile(r'require\s*\(\s*game\.ReplicatedStorage\.Modules\.([A-Za-z0-9_]+)\s*\)'), r'require(game.ReplicatedStorage.Modules.\1)'),
    (re.compile(r'require\s*\(\s*game\.ServerScriptService\.server\.Modules\.([A-Za-z0-9_]+)\s*\)'), r'require(game.ServerScriptService.Modules.\1)'),
    (re.compile(r'require\s*\(\s*game\.ServerScriptService\.server\.([A-Za-z0-9_]+)\s*\)'), r'require(game.ServerScriptService.\1)'),
    (re.compile(r'require\s*\(\s*game\.StarterPlayer\.client\.Modules\.([A-Za-z0-9_]+)\s*\)'), r'require(game.StarterPlayer.StarterPlayerScripts.Modules.\1)'),
    (re.compile(r'require\s*\(\s*game\.StarterPlayer\.client\.([A-Za-z0-9_]+)\s*\)'), r'require(game.StarterPlayer.StarterPlayerScripts.\1)'),
    (re.compile(r'require\s*\(\s*game\.ServerScriptService\.server\.Modules\s*\)'), r'require(game.ServerScriptService.Modules)'),
    (re.compile(r'require\s*\(\s*game\.StarterPlayer\.client\.Modules\s*\)'), r'require(game.StarterPlayer.StarterPlayerScripts.Modules)'),
    (re.compile(r'require\s*\(\s*game\.ReplicatedStorage\.shared\.Modules\s*\)'), r'require(game.ReplicatedStorage.Modules)'),
    (re.compile(r'require\s*\(\s*game\.ReplicatedStorage\.shared\s*\)'), r'require(game.ReplicatedStorage.Shared)'),

    # Local patterns (script.Parent, script.Parent.Modules, script.Parent:FindFirstChild)
    (re.compile(r'require\s*\(\s*script\.Parent\.Modules\.([A-Za-z0-9_]+)\s*\)'), r'require(game.ServerScriptService.Modules.\1)'),
    (re.compile(r'require\s*\(\s*script\.Parent\.([A-Za-z0-9_]+)\s*\)'), r'require(game.ServerScriptService.\1)'),
    (re.compile(r'require\s*\(\s*script\.Parent:FindFirstChild\(\s*[\'"]([A-Za-z0-9_]+)[\'"]\s*\)\s*\)'), r'require(game.ServerScriptService.Modules.\1)'),
]

def update_requires_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content
    changed = False

    # Find and print all require statements
    for match in re.finditer(r'require\s*\((.*?)\)', content):
        print(f"Found in {filepath}: {match.group(0)}")

    # Apply all patterns
    for pattern, replacement in REQUIRE_PATTERNS:
        new_content, n = pattern.subn(replacement, content)
        if n > 0:
            print(f"Updating {n} occurrence(s) in {filepath} using pattern: {pattern.pattern}")
            content = new_content
            changed = True

    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {filepath}\n")

def walk_and_update(root):
    for dirpath, _, filenames in os.walk(root):
        for filename in filenames:
            if filename.endswith('.luau') or filename.endswith('.lua'):
                update_requires_in_file(os.path.join(dirpath, filename))

if __name__ == "__main__":
    # Change this to your project root if needed
    walk_and_update("src")