import os
import re
from collections import defaultdict, deque
from typing import Dict, List, Set

class ModuleAnalyzer:
    def __init__(self, root_dir: str):
        self.root_dir = root_dir
        self.dependencies: Dict[str, Set[str]] = defaultdict(set)
        self.module_files: Dict[str, str] = {}
        self.visited: Set[str] = set()
        self.recursion_stack: Set[str] = set()

    def find_luau_files(self) -> List[str]:
        """Find all .luau files in the project."""
        luau_files = []
        for root, _, files in os.walk(self.root_dir):
            for file in files:
                if file.endswith('.luau'):
                    full_path = os.path.join(root, file)
                    rel_path = os.path.relpath(full_path, self.root_dir)
                    module_name = os.path.splitext(rel_path)[0].replace('\\', '/')
                    self.module_files[module_name] = full_path
                    luau_files.append(full_path)
        return luau_files

    def extract_requires(self, file_path: str) -> Set[str]:
        """Extract require statements from a Luau file."""
        requires = set()
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # Match different require patterns
            patterns = [
                r'require\s*\(\s*([^)]+)\s*\)',  # Basic require
                r'require\s*\(\s*script\.Parent([^)]+)\)',  # Relative to parent
                r'require\s*\(\s*game\.([^)]+)\)',  # Game service
                r'require\s*\(\s*([^)]+)\s*\)'  # Generic require
            ]
            
            for pattern in patterns:
                matches = re.finditer(pattern, content)
                for match in matches:
                    require_path = match.group(1).strip()
                    # Clean up the path
                    require_path = require_path.replace('"', '').replace("'", '')
                    requires.add(require_path)
                    
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
        
        return requires

    def build_dependency_graph(self):
        """Build the dependency graph for all modules."""
        for module_name, file_path in self.module_files.items():
            requires = self.extract_requires(file_path)
            self.dependencies[module_name] = requires

    def find_circular_dependencies(self) -> List[List[str]]:
        """Find all circular dependencies in the module graph."""
        circular_deps = []
        
        def dfs(module: str, path: List[str]):
            if module in self.recursion_stack:
                # Found a cycle
                cycle_start = path.index(module)
                cycle = path[cycle_start:] + [module]
                circular_deps.append(cycle)
                return
            
            if module in self.visited:
                return
                
            self.visited.add(module)
            self.recursion_stack.add(module)
            
            for dep in self.dependencies[module]:
                if dep in self.module_files:  # Only follow dependencies we know about
                    dfs(dep, path + [module])
                    
            self.recursion_stack.remove(module)

        # Start DFS from each module
        for module in self.module_files:
            if module not in self.visited:
                dfs(module, [])

        return circular_deps

    def analyze(self):
        """Run the full analysis."""
        print("Finding Luau files...")
        self.find_luau_files()
        
        print("\nBuilding dependency graph...")
        self.build_dependency_graph()
        
        print("\nAnalyzing dependencies...")
        circular_deps = self.find_circular_dependencies()
        
        if circular_deps:
            print("\nFound circular dependencies:")
            for cycle in circular_deps:
                print(" -> ".join(cycle))
        else:
            print("\nNo circular dependencies found!")
            
        # Print module statistics
        print(f"\nTotal modules found: {len(self.module_files)}")
        print(f"Total dependencies found: {sum(len(deps) for deps in self.dependencies.values())}")

def main():
    # Get the current directory
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Create analyzer
    analyzer = ModuleAnalyzer(current_dir)
    
    # Run analysis
    analyzer.analyze()

if __name__ == "__main__":
    main() 