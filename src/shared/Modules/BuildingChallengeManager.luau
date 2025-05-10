local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local BuildingChallengeManager = {}

-- Local state
local activeChallenges = {} -- Currently active challenges
local challengeSubmissions = {} -- Player submissions for challenges
local challengeVotes = {} -- Votes for challenge submissions
local challengeRewards = {} -- Rewards for challenge winners
local challengeLeaderboards = {} -- Leaderboards for each challenge
local playerAchievements = {} -- Player achievements and progress

-- Challenge categories and difficulties
local CHALLENGE_CATEGORIES = {
    "Architecture",
    "Landscaping",
    "Interior Design",
    "Fantasy",
    "Sci-Fi",
    "Historical",
    "Modern",
    "Abstract"
}

local CHALLENGE_DIFFICULTIES = {
    {
        name = "Beginner",
        rewardMultiplier = 1,
        timeLimit = 7 * 24 * 60 * 60 -- 7 days
    },
    {
        name = "Intermediate",
        rewardMultiplier = 1.5,
        timeLimit = 10 * 24 * 60 * 60 -- 10 days
    },
    {
        name = "Advanced",
        rewardMultiplier = 2,
        timeLimit = 14 * 24 * 60 * 60 -- 14 days
    }
}

-- Special rewards
local SPECIAL_REWARDS = {
    {
        name = "Master Builder",
        description = "Win 10 challenges",
        reward = 5000
    },
    {
        name = "Community Favorite",
        description = "Get 100 total votes",
        reward = 3000
    },
    {
        name = "Theme Expert",
        description = "Win challenges in 5 different categories",
        reward = 4000
    }
}

-- Initialize building challenges system
function BuildingChallengeManager.init()
    -- Create remote events
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    local getChallengesEvent = Instance.new("RemoteEvent")
    getChallengesEvent.Name = "GetChallenges"
    getChallengesEvent.Parent = remotes
    
    local submitChallengeEvent = Instance.new("RemoteEvent")
    submitChallengeEvent.Name = "SubmitChallenge"
    submitChallengeEvent.Parent = remotes
    
    local voteChallengeEvent = Instance.new("RemoteEvent")
    voteChallengeEvent.Name = "VoteChallenge"
    voteChallengeEvent.Parent = remotes
    
    local getSubmissionsEvent = Instance.new("RemoteEvent")
    getSubmissionsEvent.Name = "GetSubmissions"
    getSubmissionsEvent.Parent = remotes
    
    local getVotesEvent = Instance.new("RemoteEvent")
    getVotesEvent.Name = "GetVotes"
    getVotesEvent.Parent = remotes
    
    -- Set up event handlers
    getChallengesEvent.OnServerEvent:Connect(function(player)
        BuildingChallengeManager.getChallenges(player)
    end)
    
    submitChallengeEvent.OnServerEvent:Connect(function(player, challengeId, submission)
        BuildingChallengeManager.submitChallenge(player, challengeId, submission)
    end)
    
    voteChallengeEvent.OnServerEvent:Connect(function(player, submissionId)
        BuildingChallengeManager.voteChallenge(player, submissionId)
    end)
    
    getSubmissionsEvent.OnServerEvent:Connect(function(player, challengeId)
        BuildingChallengeManager.getSubmissions(player, challengeId)
    end)
    
    getVotesEvent.OnServerEvent:Connect(function(player, submissionId)
        BuildingChallengeManager.getVotes(player, submissionId)
    end)
    
    -- Set up player connection/disconnection handlers
    Players.PlayerAdded:Connect(function(player)
        BuildingChallengeManager.handlePlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        BuildingChallengeManager.handlePlayerLeave(player)
    end)
    
    -- Start challenge scheduler
    BuildingChallengeManager.startChallengeScheduler()
end

-- Handle player joining
function BuildingChallengeManager.handlePlayerJoin(player)
    -- Initialize player's challenge data
    challengeSubmissions[player.UserId] = {}
    challengeVotes[player.UserId] = {}
end

-- Handle player leaving
function BuildingChallengeManager.handlePlayerLeave(player)
    -- Clean up player's challenge data
    challengeSubmissions[player.UserId] = nil
    challengeVotes[player.UserId] = nil
end

-- Start challenge scheduler
function BuildingChallengeManager.startChallengeScheduler()
    -- Schedule weekly challenges
    task.spawn(function()
        while true do
            -- Create new weekly challenge
            BuildingChallengeManager.createWeeklyChallenge()
            
            -- Wait for one week
            task.wait(7 * 24 * 60 * 60)
            
            -- End current challenge and announce winners
            BuildingChallengeManager.endWeeklyChallenge()
        end
    end)
    
    -- Schedule theme-based challenges
    task.spawn(function()
        while true do
            -- Create new theme challenge
            BuildingChallengeManager.createThemeChallenge()
            
            -- Wait for two weeks
            task.wait(14 * 24 * 60 * 60)
            
            -- End current challenge and announce winners
            BuildingChallengeManager.endThemeChallenge()
        end
    end)
end

-- Create weekly challenge
function BuildingChallengeManager.createWeeklyChallenge()
    local challengeId = HttpService:GenerateGUID()
    local difficulty = CHALLENGE_DIFFICULTIES[math.random(1, #CHALLENGE_DIFFICULTIES)]
    local category = CHALLENGE_CATEGORIES[math.random(1, #CHALLENGE_CATEGORIES)]
    
    local challenge = {
        id = challengeId,
        type = "weekly",
        title = "Weekly Building Challenge",
        description = "Create something amazing!",
        category = category,
        difficulty = difficulty.name,
        startTime = os.time(),
        endTime = os.time() + difficulty.timeLimit,
        rewards = {
            first = 1000 * difficulty.rewardMultiplier,
            second = 500 * difficulty.rewardMultiplier,
            third = 250 * difficulty.rewardMultiplier
        }
    }
    
    activeChallenges[challengeId] = challenge
    challengeLeaderboards[challengeId] = {}
    
    -- Notify all players
    BuildingChallengeManager.notifyNewChallenge(challenge)
end

-- Create theme challenge
function BuildingChallengeManager.createThemeChallenge()
    local challengeId = HttpService:GenerateGUID()
    local difficulty = CHALLENGE_DIFFICULTIES[math.random(1, #CHALLENGE_DIFFICULTIES)]
    local category = CHALLENGE_CATEGORIES[math.random(1, #CHALLENGE_CATEGORIES)]
    
    local challenge = {
        id = challengeId,
        type = "theme",
        title = "Theme Building Challenge",
        description = "Build according to the theme!",
        category = category,
        difficulty = difficulty.name,
        theme = BuildingChallengeManager.generateTheme(),
        startTime = os.time(),
        endTime = os.time() + difficulty.timeLimit,
        rewards = {
            first = 2000 * difficulty.rewardMultiplier,
            second = 1000 * difficulty.rewardMultiplier,
            third = 500 * difficulty.rewardMultiplier
        }
    }
    
    activeChallenges[challengeId] = challenge
    challengeLeaderboards[challengeId] = {}
    
    -- Notify all players
    BuildingChallengeManager.notifyNewChallenge(challenge)
end

-- Generate theme
function BuildingChallengeManager.generateTheme()
    local themes = {
        "Futuristic City",
        "Medieval Castle",
        "Underwater World",
        "Space Station",
        "Ancient Temple",
        "Modern Home",
        "Fantasy Kingdom",
        "Steampunk Workshop"
    }
    
    return themes[math.random(1, #themes)]
end

-- End weekly challenge
function BuildingChallengeManager.endWeeklyChallenge()
    for challengeId, challenge in pairs(activeChallenges) do
        if challenge.type == "weekly" then
            -- Calculate winners
            local winners = BuildingChallengeManager.calculateWinners(challengeId)
            
            -- Award rewards
            BuildingChallengeManager.awardRewards(challenge, winners)
            
            -- Remove challenge
            activeChallenges[challengeId] = nil
            
            -- Notify players
            BuildingChallengeManager.notifyChallengeEnd(challenge, winners)
        end
    end
end

-- End theme challenge
function BuildingChallengeManager.endThemeChallenge()
    for challengeId, challenge in pairs(activeChallenges) do
        if challenge.type == "theme" then
            -- Calculate winners
            local winners = BuildingChallengeManager.calculateWinners(challengeId)
            
            -- Award rewards
            BuildingChallengeManager.awardRewards(challenge, winners)
            
            -- Remove challenge
            activeChallenges[challengeId] = nil
            
            -- Notify players
            BuildingChallengeManager.notifyChallengeEnd(challenge, winners)
        end
    end
end

-- Calculate winners
function BuildingChallengeManager.calculateWinners(challengeId)
    local submissions = challengeSubmissions[challengeId]
    if not submissions then return {} end
    
    -- Sort submissions by votes
    local sortedSubmissions = {}
    for submissionId, submission in pairs(submissions) do
        table.insert(sortedSubmissions, {
            id = submissionId,
            votes = #(challengeVotes[submissionId] or {})
        })
    end
    
    table.sort(sortedSubmissions, function(a, b)
        return a.votes > b.votes
    end)
    
    -- Get top 3
    local winners = {}
    for i = 1, math.min(3, #sortedSubmissions) do
        table.insert(winners, sortedSubmissions[i])
    end
    
    return winners
end

-- Award rewards
function BuildingChallengeManager.awardRewards(challenge, winners)
    for i, winner in ipairs(winners) do
        local player = Players:GetPlayerByUserId(winner.userId)
        if player then
            local rewardTypes = {"first", "second", "third"}
            local reward = challenge.rewards[rewardTypes[i]]
            if reward then
                -- TODO: Award reward to player
            end
        end
    end
end

-- Get challenges
function BuildingChallengeManager.getChallenges(player)
    return true, activeChallenges
end

-- Submit challenge
function BuildingChallengeManager.submitChallenge(player, challengeId, submission)
    local userId = player.UserId
    
    -- Validate challenge
    local challenge = activeChallenges[challengeId]
    if not challenge then
        return false, "Challenge not found"
    end
    
    -- Validate submission
    if not submission then
        return false, "Invalid submission"
    end
    
    -- Create submission
    local submissionId = HttpService:GenerateGUID()
    local submissionData = {
        id = submissionId,
        userId = userId,
        username = player.Name,
        challengeId = challengeId,
        submission = submission,
        submittedAt = os.time()
    }
    
    -- Save submission
    challengeSubmissions[challengeId] = challengeSubmissions[challengeId] or {}
    challengeSubmissions[challengeId][submissionId] = submissionData
    
    return true, "Submission successful"
end

-- Vote challenge
function BuildingChallengeManager.voteChallenge(player, submissionId)
    local userId = player.UserId
    
    -- Find submission
    local submission = nil
    local challengeId = nil
    for cId, submissions in pairs(challengeSubmissions) do
        if submissions[submissionId] then
            submission = submissions[submissionId]
            challengeId = cId
            break
        end
    end
    
    if not submission then
        return false, "Submission not found"
    end
    
    -- Check if player has already voted
    if challengeVotes[userId] and challengeVotes[userId][submissionId] then
        return false, "Already voted"
    end
    
    -- Add vote
    challengeVotes[userId] = challengeVotes[userId] or {}
    challengeVotes[userId][submissionId] = true
    
    return true, "Vote recorded"
end

-- Get submissions
function BuildingChallengeManager.getSubmissions(player, challengeId)
    -- Validate challenge
    local challenge = activeChallenges[challengeId]
    if not challenge then
        return false, "Challenge not found"
    end
    
    -- Get submissions
    local submissions = challengeSubmissions[challengeId] or {}
    
    return true, submissions
end

-- Get votes
function BuildingChallengeManager.getVotes(player, submissionId)
    -- Find submission
    local submission = nil
    for _, submissions in pairs(challengeSubmissions) do
        if submissions[submissionId] then
            submission = submissions[submissionId]
            break
        end
    end
    
    if not submission then
        return false, "Submission not found"
    end
    
    -- Get votes
    local votes = challengeVotes[submissionId] or {}
    
    return true, votes
end

-- Notify new challenge
function BuildingChallengeManager.notifyNewChallenge(challenge)
    -- TODO: Implement notification system
    -- This could include:
    -- - In-game notifications
    -- - UI updates
    -- - Sound effects
end

-- Notify challenge end
function BuildingChallengeManager.notifyChallengeEnd(challenge, winners)
    -- TODO: Implement notification system
    -- This could include:
    -- - In-game notifications
    -- - UI updates
    -- - Sound effects
    -- - Winner announcements
end

-- Update leaderboard
function BuildingChallengeManager.updateLeaderboard(challengeId, submissionId, votes)
    local leaderboard = challengeLeaderboards[challengeId]
    if not leaderboard then return end
    
    leaderboard[submissionId] = votes
    
    -- Sort leaderboard
    local sortedEntries = {}
    for id, voteCount in pairs(leaderboard) do
        table.insert(sortedEntries, {id = id, votes = voteCount})
    end
    
    table.sort(sortedEntries, function(a, b)
        return a.votes > b.votes
    end)
    
    -- Update top 10
    challengeLeaderboards[challengeId] = {}
    for i = 1, math.min(10, #sortedEntries) do
        challengeLeaderboards[challengeId][i] = sortedEntries[i]
    end
end

-- Check achievements
function BuildingChallengeManager.checkAchievements(player)
    local userId = player.UserId
    local achievements = playerAchievements[userId] or {
        wins = 0,
        totalVotes = 0,
        categoriesWon = {}
    }
    
    -- Check for special rewards
    for _, reward in ipairs(SPECIAL_REWARDS) do
        if reward.name == "Master Builder" and achievements.wins >= 10 then
            BuildingChallengeManager.awardSpecialReward(player, reward)
        elseif reward.name == "Community Favorite" and achievements.totalVotes >= 100 then
            BuildingChallengeManager.awardSpecialReward(player, reward)
        elseif reward.name == "Theme Expert" and #achievements.categoriesWon >= 5 then
            BuildingChallengeManager.awardSpecialReward(player, reward)
        end
    end
end

-- Award special reward
function BuildingChallengeManager.awardSpecialReward(player, reward)
    -- TODO: Implement special reward distribution
    -- This could include:
    -- - Currency rewards
    -- - Special items
    -- - Achievement badges
    -- - Title unlocks
end

-- Get leaderboard
function BuildingChallengeManager.getLeaderboard(challengeId)
    return challengeLeaderboards[challengeId] or {}
end

-- Get player achievements
function BuildingChallengeManager.getPlayerAchievements(player)
    return playerAchievements[player.UserId] or {
        wins = 0,
        totalVotes = 0,
        categoriesWon = {}
    }
end

return BuildingChallengeManager 