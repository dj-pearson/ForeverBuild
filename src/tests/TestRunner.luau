local TestRunner = {}

-- Test statistics
local stats = {
    total = 0,
    passed = 0,
    failed = 0,
    errors = 0
}

-- Print with prefix
local function printWithPrefix(prefix, text)
    print(prefix .. " " .. text)
end

-- Run a single test file
function TestRunner.runTestFile(testFile)
    printWithPrefix("📄", "Running tests in: " .. testFile.Name)
    
    local success, result = pcall(function()
        return require(testFile)
    end)
    
    if not success then
        printWithPrefix("❌", "Error loading test file: " .. tostring(result))
        stats.errors = stats.errors + 1
        return false
    end
    
    return true
end

-- Run all tests in a directory
function TestRunner.runTests(directory)
    printWithPrefix("🚀", "=== Starting Test Suite ===\n")
    
    -- Reset stats
    stats.total = 0
    stats.passed = 0
    stats.failed = 0
    stats.errors = 0
    
    -- Find all test files
    local testFiles = {}
    for _, file in ipairs(directory:GetChildren()) do
        if file.Name:match("%.test%.luau$") then
            table.insert(testFiles, file)
        end
    end
    
    -- Sort test files alphabetically
    table.sort(testFiles, function(a, b)
        return a.Name < b.Name
    end)
    
    -- Run each test file
    for _, testFile in ipairs(testFiles) do
        TestRunner.runTestFile(testFile)
    end
    
    -- Print summary
    printWithPrefix("📊", "=== Test Summary ===")
    printWithPrefix("📝", "Total Tests: " .. stats.total)
    printWithPrefix("✅", "Passed: " .. stats.passed)
    printWithPrefix("❌", "Failed: " .. stats.failed)
    printWithPrefix("⚠️", "Errors: " .. stats.errors)
    
    -- Return success if all tests passed
    return stats.failed == 0 and stats.errors == 0
end

-- Add test result
function TestRunner.addResult(success, message)
    stats.total = stats.total + 1
    if success then
        stats.passed = stats.passed + 1
        printWithPrefix("✅", message)
    else
        stats.failed = stats.failed + 1
        printWithPrefix("❌", message)
    end
end

-- Add test error
function TestRunner.addError(message)
    stats.errors = stats.errors + 1
    printWithPrefix("⚠️", message)
end

return TestRunner 