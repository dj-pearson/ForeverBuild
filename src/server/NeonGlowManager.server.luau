-- EnhancedGlowManager.lua
-- Place this in ServerScriptService

local TweenService = game:GetService("TweenService")
wait(1) -- Wait for everything to load

print("=== Enhanced Glow Manager Starting ===")

-- Color definitions
local GLOW_COLORS = {
	Red = Color3.fromRGB(255, 0, 0),
	Blue = Color3.fromRGB(0, 0, 255),
	Green = Color3.fromRGB(0, 255, 0),
	Purple = Color3.fromRGB(147, 39, 212),
	Yellow = Color3.fromRGB(255, 255, 0),
	Cyan = Color3.fromRGB(0, 255, 255),
	White = Color3.fromRGB(255, 255, 255),
	Orange = Color3.fromRGB(255, 128, 0)
}

-- Animation settings
local GLOW_TWEEN_INFO = TweenInfo.new(
	2,                      -- Duration
	Enum.EasingStyle.Sine,   -- Easing Style
	Enum.EasingDirection.InOut, -- Easing Direction
	-1,                     -- Repeat count (-1 = forever)
	true                    -- Reverse
)

-- Store tweens for cleanup
local activeTweens = {}

-- Recursively search through all containers
local function findAllGlowModels(parent)
	local glowModels = {}

	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("Model") and child:GetAttribute("GlowColor") then
			table.insert(glowModels, child)
		elseif child:IsA("Folder") then
			local nestedModels = findAllGlowModels(child)
			for _, model in ipairs(nestedModels) do
				table.insert(glowModels, model)
			end
		end
	end

	return glowModels
end

-- Create an outer glow effect (transparent part surrounding the cube)
local function createOuterGlow(part, color)
	local outerGlow = Instance.new("Part")
	outerGlow.Name = "OuterGlow"
	outerGlow.Parent = part.Parent
	outerGlow.Material = Enum.Material.Neon
	outerGlow.BrickColor = BrickColor.new(color)
	outerGlow.Color = color
	outerGlow.Anchored = true
	outerGlow.CanCollide = false
	outerGlow.Transparency = 0.7

	-- Handle different part types
	if part:IsA("Part") then
		outerGlow.Shape = part.Shape
	else
		-- For UnionOperations or other part types, default to Block
		outerGlow.Shape = Enum.PartType.Block
	end

	outerGlow.Size = part.Size * 1.1  -- Slightly larger
	outerGlow.CFrame = part.CFrame

	-- Keep it connected to the main part
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = part
	weld.Part1 = outerGlow
	weld.Parent = part

	return outerGlow
end

-- Enhanced glow function
local function makePartGlow(part, color)
	print(string.format("  Enhancing glow for %s (%s)", part.Name, part.ClassName))

	-- 1. Set main part properties based on part type
	if part:IsA("Part") then
		part.Material = Enum.Material.ForceField  -- More translucent than Neon
	elseif part:IsA("UnionOperation") then
		-- UnionOperations have limited material options
		part.Material = Enum.Material.Neon
	end

	part.Color = color
	part.Transparency = 0.2  -- Slightly transparent

	-- 2. Add/update PointLight
	local light = part:FindFirstChild("PointLight") or Instance.new("PointLight")
	light.Parent = part
	light.Color = color
	light.Brightness = 3  -- Brighter
	light.Range = 15      -- Larger range

	-- 3. Create outer glow effect
	local outerGlow = createOuterGlow(part, color)

	-- 4. Add pulsing animation
	local brightColor = color
	local darkColor = Color3.new(color.R * 0.4, color.G * 0.4, color.B * 0.4)

	-- Animate main part
	local partTween = TweenService:Create(part, GLOW_TWEEN_INFO, {
		Color = darkColor,
		Transparency = 0.5
	})

	-- Animate outer glow
	local glowTween = TweenService:Create(outerGlow, GLOW_TWEEN_INFO, {
		Color = darkColor,
		Transparency = 0.9
	})

	-- Animate light
	local lightTween = TweenService:Create(light, GLOW_TWEEN_INFO, {
		Brightness = 1,
		Range = 8
	})

	-- Store tweens for later cleanup
	table.insert(activeTweens, partTween)
	table.insert(activeTweens, glowTween)
	table.insert(activeTweens, lightTween)

	-- Start animations
	partTween:Play()
	glowTween:Play()
	lightTween:Play()

	print(string.format("  ✓ Enhanced glow applied to %s", part.Name))
end

-- Find all glow models in workspace
local allGlowModels = findAllGlowModels(workspace)
print(string.format("Found %d glow models", #allGlowModels))

-- Process each glow model
for _, model in ipairs(allGlowModels) do
	local colorName = model:GetAttribute("GlowColor")
	local color = GLOW_COLORS[colorName]

	if color then
		print(string.format("Processing: %s (Color: %s)", model.Name, colorName))

		-- Apply enhanced glow to all parts in the model
		for _, part in ipairs(model:GetChildren()) do
			if part:IsA("BasePart") then
				makePartGlow(part, color)
			end
		end
	else
		warn(string.format("Unknown color: %s for model: %s", colorName, model.Name))
	end
end

print("=== Enhanced Glow Manager Complete! ===")

-- Cleanup function
local function cleanup()
	for _, tween in ipairs(activeTweens) do
		tween:Cancel()
	end
	activeTweens = {}
end

-- Store for global access
_G.EnhancedGlowManager = {
	GLOW_COLORS = GLOW_COLORS,
	makePartGlow = makePartGlow,
	findAllGlowModels = findAllGlowModels,
	cleanup = cleanup
}