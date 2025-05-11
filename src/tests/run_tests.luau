local TestRunner = require(game.ServerScriptService.TestRunner)

-- Run all tests
print("Starting test suite...")
local success = TestRunner.runTests(script.Parent)

-- Print final status
if success then
    print("✅ All tests passed!")
else
    print("❌ Some tests failed!")
end 