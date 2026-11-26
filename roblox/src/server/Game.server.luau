-- Paper One Duel: Orbit Station. Server: runs the room, holds the answers, and tells clients what to show.
-- One Roblox server is one room (set Max Players to 8 in Game Settings).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Banks = require(script.Parent:WaitForChild("Banks"))

local byId = {}
for _, key in ipairs(Banks.order) do
	for _, q in ipairs(Banks[key].questions) do
		byId[q.id] = q
	end
end

-- Remotes ------------------------------------------------------------------
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage
local StateEvent = Instance.new("RemoteEvent")
StateEvent.Name = "State"
StateEvent.Parent = remotes
local ActionEvent = Instance.new("RemoteEvent")
ActionEvent.Name = "Action"
ActionEvent.Parent = remotes

-- The station --------------------------------------------------------------
local pads = {}
local function part(props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do
		p[k] = v
	end
	return p
end
local function buildStation()
	Lighting.ClockTime = 0
	Lighting.Brightness = 1
	Lighting.Ambient = Color3.fromRGB(70, 80, 130)
	Lighting.OutdoorAmbient = Color3.fromRGB(60, 70, 120)
	local folder = Instance.new("Folder")
	folder.Name = "OrbitStation"
	folder.Parent = workspace
	local c = Config.CENTER
	-- deck
	part({ Name = "Deck", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1, 36, 36), Material = Enum.Material.DiamondPlate,
		Color = Config.COLORS.panel, CFrame = CFrame.new(c) * CFrame.Angles(0, 0, math.rad(90)), Parent = folder })
	-- reactor ring in the middle (the "round table")
	part({ Name = "ReactorRing", Shape = Enum.PartType.Cylinder, Size = Vector3.new(2, 12, 12), Material = Enum.Material.Metal,
		Color = Color3.fromRGB(40, 46, 90), CFrame = CFrame.new(c + Vector3.new(0, 1.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Parent = folder })
	part({ Name = "ReactorGlow", Shape = Enum.PartType.Cylinder, Size = Vector3.new(2.2, 8, 8), Material = Enum.Material.Neon,
		Color = Config.COLORS.accent, CFrame = CFrame.new(c + Vector3.new(0, 1.6, 0)) * CFrame.Angles(0, 0, math.rad(90)), Parent = folder })
	-- crew pads
	for i = 1, Config.MAX_PLAYERS do
		local a = (i - 1) / Config.MAX_PLAYERS * math.pi * 2
		local pos = c + Vector3.new(math.cos(a) * Config.SEAT_RADIUS, 1, math.sin(a) * Config.SEAT_RADIUS)
		pads[i] = part({ Name = "Pad" .. i, Size = Vector3.new(4, 0.6, 4), Material = Enum.Material.Neon, Color = Config.SEAT_COLORS[i],
			CFrame = CFrame.lookAt(pos, Vector3.new(c.X, pos.Y, c.Z)), Parent = folder })
	end
	-- a spawn on the deck so new players arrive at the station
	local spawn = Instance.new("SpawnLocation")
	spawn.Anchored = true
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.CFrame = CFrame.new(c + Vector3.new(0, 1, 15))
	spawn.Material = Enum.Material.Neon
	spawn.Color = Config.COLORS.accent
	spawn.Neutral = true
	spawn.Parent = folder
end
buildStation()

local core -- the Hot Core that hovers over the holder
local function makeCore()
	if core then core:Destroy() end
	core = part({ Name = "HotCore", Shape = Enum.PartType.Ball, Size = Vector3.new(2.4, 2.4, 2.4), Material = Enum.Material.Neon,
		Color = Config.COLORS.core, CanCollide = false, Parent = workspace })
	local light = Instance.new("PointLight")
	light.Color = Config.COLORS.core
	light.Range = 14
	light.Brightness = 3
	light.Parent = core
	local fire = Instance.new("Fire")
	fire.Size = 3
	fire.Heat = 6
	fire.Color = Config.COLORS.core
	fire.Parent = core
end
local function removeCore()
	if core then core:Destroy() end
	core = nil
end

-- Progress (DataStore) -----------------------------------------------------
local store = nil
pcall(function()
	store = DataStoreService:GetDataStore(Config.DATASTORE)
end)
local profiles = {}

local function masteredCount(profile)
	local n = 0
	for _, r in pairs(profile.q) do
		if r.last == 1 then n = n + 1 end
	end
	return n
end
local function updateLeaderstats(player)
	local profile = profiles[player.UserId]
	local stats = player:FindFirstChild("leaderstats")
	if not profile or not stats then return end
	stats.Wins.Value = profile.w
	stats.Mastered.Value = masteredCount(profile)
end
local function loadProfile(player)
	local profile = { q = {}, w = 0, l = 0, d = 0 }
	if store then
		local ok, data = pcall(function()
			return store:GetAsync("u_" .. player.UserId)
		end)
		if ok and type(data) == "table" then
			profile.q = type(data.q) == "table" and data.q or {}
			profile.w = tonumber(data.w) or 0
			profile.l = tonumber(data.l) or 0
			profile.d = tonumber(data.d) or 0
		end
	end
	profiles[player.UserId] = profile
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Parent = stats
	local mastered = Instance.new("IntValue")
	mastered.Name = "Mastered"
	mastered.Parent = stats
	stats.Parent = player
	updateLeaderstats(player)
end
local function saveProfile(userId)
	local profile = profiles[userId]
	if not store or not profile then return end
	pcall(function()
		store:SetAsync("u_" .. userId, profile)
	end)
end
local function record(player, qid, ok)
	local profile = profiles[player.UserId]
	if not profile then return end
	local r = profile.q[qid] or { n = 0, c = 0 }
	r.n = r.n + 1
	if ok then r.c = r.c + 1 end
	r.last = ok and 1 or 0
	profile.q[qid] = r
	updateLeaderstats(player)
end

-- Game state ---------------------------------------------------------------
local G = {
	phase = "lobby", mode = "race", subject = "h2", rounds = 10, lives = 2, fuse = 30,
	seats = {}, qs = {}, k = 0, question = nil, answers = {}, ready = {},
	turn = 1, deadline = 0, result = nil, winners = {}, message = "", token = 0,
}

local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end
local function seatOf(player)
	for i, s in ipairs(G.seats) do
		if s.player == player then return i end
	end
	return nil
end
local function present(s)
	return s.player.Parent == Players
end
local function presentCount()
	local n = 0
	for _, s in ipairs(G.seats) do
		if present(s) then n = n + 1 end
	end
	return n
end

local function publicState()
	local st = {
		phase = G.phase, mode = G.mode, subject = G.subject, subjectName = Banks[G.subject].name,
		rounds = G.rounds, lives = G.lives, fuse = G.fuse, k = G.k, n = #G.qs, turn = G.turn,
		deadline = G.deadline, message = G.message, seats = {}, winners = G.winners,
		hostId = G.seats[1] and G.seats[1].userId or 0,
		subjects = {},
	}
	for _, key in ipairs(Banks.order) do
		table.insert(st.subjects, { key = key, name = Banks[key].name })
	end
	for i, s in ipairs(G.seats) do
		st.seats[i] = {
			userId = s.userId, name = s.name, score = s.score, livesLeft = s.livesLeft,
			answered = G.answers[s.userId] ~= nil, ready = G.ready[s.userId] == true, present = present(s),
		}
	end
	if G.question then
		local q = G.question
		st.question = { id = q.id, topic = q.topic, q = q.q, options = q.options }
		if G.phase == "reveal" then
			st.question.correct = q.correct
			st.question.x = q.x
			st.result = G.result
		end
	end
	return st
end
local function broadcast()
	StateEvent:FireAllClients(publicState())
end

local function refreshLobbySeats()
	local seats = {}
	for _, s in ipairs(G.seats) do
		if present(s) and #seats < Config.MAX_PLAYERS then table.insert(seats, s) end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		local found = false
		for _, s in ipairs(seats) do
			if s.player == p then found = true end
		end
		if not found and #seats < Config.MAX_PLAYERS then
			table.insert(seats, { player = p, userId = p.UserId, name = p.DisplayName, score = 0, livesLeft = 0 })
		end
	end
	G.seats = seats
end

local function holdCrew(anchor)
	for i, s in ipairs(G.seats) do
		local char = s.player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			if anchor then
				hrp.CFrame = pads[i].CFrame + Vector3.new(0, 3.2, 0)
			end
			hrp.Anchored = anchor
		end
	end
end
local function placeCore()
	local s = G.seats[G.turn]
	local head = s and s.player.Character and s.player.Character:FindFirstChild("Head")
	if not core then makeCore() end
	if head then
		core.CFrame = CFrame.new(head.Position + Vector3.new(0, 3, 0))
	else
		core.CFrame = CFrame.new(pads[G.turn].Position + Vector3.new(0, 7, 0))
	end
end
local function boomAt(pos)
	local ex = Instance.new("Explosion")
	ex.Position = pos
	ex.BlastRadius = 6
	ex.BlastPressure = 0              -- visual only: nobody gets flung
	ex.DestroyJointRadiusPercent = 0  -- and nobody's character breaks
	ex.Parent = workspace
end

local function prepareQuestion(id)
	local q = byId[id]
	local order = shuffle({ 1, 2, 3, 4 })
	local options, correct = {}, 1
	for d = 1, 4 do
		options[d] = q.o[order[d]]
		if order[d] == q.a then correct = d end
	end
	return { id = q.id, topic = q.topic, q = q.q, options = options, correct = correct, x = q.x }
end

local function aliveSeats()
	local list = {}
	for i, s in ipairs(G.seats) do
		if s.livesLeft > 0 and present(s) then table.insert(list, i) end
	end
	return list
end
local function nextAlive(from)
	local n = #G.seats
	for d = 1, n do
		local i = (from + d - 1) % n + 1
		local s = G.seats[i]
		if s.livesLeft > 0 and present(s) then return i end
	end
	return from
end

local startQuestion, resolve, advance, endGame

endGame = function(abandoned)
	G.phase = "ended"
	G.token = G.token + 1
	G.winners = {}
	removeCore()
	holdCrew(false)
	if G.mode == "race" then
		local best = -1
		for _, s in ipairs(G.seats) do
			if s.score > best then best = s.score end
		end
		for i, s in ipairs(G.seats) do
			if s.score == best then table.insert(G.winners, i) end
		end
	else
		for _, i in ipairs(aliveSeats()) do
			table.insert(G.winners, i)
		end
	end
	if abandoned then
		G.message = "Everyone else left, so the game ended. It isn't counted."
	else
		for i, s in ipairs(G.seats) do
			local profile = profiles[s.userId]
			if profile then
				local won = table.find(G.winners, i) ~= nil
				if won and #G.winners == 1 then
					profile.w = profile.w + 1
				elseif won then
					profile.d = profile.d + 1
				else
					profile.l = profile.l + 1
				end
				if present(s) then updateLeaderstats(s.player) end
				task.spawn(saveProfile, s.userId)
			end
		end
		local names = {}
		for _, i in ipairs(G.winners) do
			table.insert(names, G.seats[i].name)
		end
		if #names == 0 then
			G.message = "Nobody survived the core."
		elseif G.mode == "race" then
			G.message = table.concat(names, " and ") .. (#names == 1 and " wins!" or " share first place!")
		else
			G.message = names[1] .. " is the last crew member standing!"
		end
	end
	broadcast()
	local my = G.token
	task.delay(20, function()
		if G.token == my and G.phase == "ended" then
			G.phase = "lobby"
			G.question = nil
			G.message = ""
			refreshLobbySeats()
			broadcast()
		end
	end)
end

startQuestion = function()
	G.k = G.k + 1
	G.question = prepareQuestion(G.qs[(G.k - 1) % #G.qs + 1])
	G.answers = {}
	G.ready = {}
	G.result = nil
	G.phase = "question"
	local lim = G.mode == "race" and Config.RACE_TIME or G.fuse
	G.deadline = workspace:GetServerTimeNow() + lim
	G.token = G.token + 1
	if G.mode == "bomb" then placeCore() end
	broadcast()
	local my = G.token
	task.delay(lim + 0.3, function()
		if G.token == my and G.phase == "question" then resolve() end
	end)
end

resolve = function()
	local q = G.question
	G.token = G.token + 1
	if G.mode == "race" then
		local winner, bestT = 0, math.huge
		local picks = {}
		for i, s in ipairs(G.seats) do
			local a = G.answers[s.userId]
			picks[i] = a and a.c or 0
			if a then
				record(s.player, q.id, a.c == q.correct)
				if a.c == q.correct and a.t < bestT then
					winner, bestT = i, a.t
				end
			end
		end
		if winner > 0 then G.seats[winner].score = G.seats[winner].score + 1 end
		G.result = { winner = winner, picks = picks }
	else
		local s = G.seats[G.turn]
		local a = G.answers[s.userId]
		local ok = a ~= nil and a.c == q.correct
		if a then record(s.player, q.id, ok) end
		if not ok then
			s.livesLeft = s.livesLeft - 1
			if core then boomAt(core.Position) end
		end
		G.result = { seat = G.turn, pick = a and a.c or 0, ok = ok }
	end
	G.phase = "reveal"
	broadcast()
	local my = G.token
	local wait = Config.REVEAL_MAX
	if G.mode == "bomb" then wait = G.result.ok and 2.5 or 4 end
	task.delay(wait, function()
		if G.token == my and G.phase == "reveal" then advance() end
	end)
end

advance = function()
	if presentCount() < 2 and not (Config.ALLOW_SOLO_IN_STUDIO and RunService:IsStudio()) then
		return endGame(true)
	end
	if G.mode == "race" then
		if G.k < #G.qs then startQuestion() else endGame(false) end
	else
		if #aliveSeats() <= 1 and #G.seats > 1 then return endGame(false) end
		if #aliveSeats() == 0 then return endGame(false) end
		G.turn = nextAlive(G.turn)
		startQuestion()
	end
end

local function startGame(opts)
	refreshLobbySeats()
	local soloOk = Config.ALLOW_SOLO_IN_STUDIO and RunService:IsStudio()
	if #G.seats < 2 and not soloOk then
		G.message = "Need at least 2 crew to launch."
		return broadcast()
	end
	G.mode = opts.mode
	G.subject = opts.subject
	G.rounds = opts.rounds
	G.lives = opts.lives
	G.fuse = opts.fuse
	local pool = {}
	for _, q in ipairs(Banks[G.subject].questions) do
		if G.mode == "race" or q.quick then table.insert(pool, q.id) end
	end
	shuffle(pool)
	G.qs = {}
	local count = G.mode == "race" and math.min(G.rounds, #pool) or #pool
	for i = 1, count do
		G.qs[i] = pool[i]
	end
	for _, s in ipairs(G.seats) do
		s.score = 0
		s.livesLeft = G.lives
	end
	G.k = 0
	G.turn = math.random(#G.seats)
	G.winners = {}
	G.message = ""
	G.phase = "countdown"
	G.deadline = workspace:GetServerTimeNow() + Config.COUNTDOWN
	G.token = G.token + 1
	holdCrew(true)
	broadcast()
	local my = G.token
	task.delay(Config.COUNTDOWN, function()
		if G.token == my then startQuestion() end
	end)
end

local function pick(list, value, default)
	for _, v in ipairs(list) do
		if v == value then return v end
	end
	return default
end

ActionEvent.OnServerEvent:Connect(function(player, action)
	if type(action) ~= "table" then return end
	local seat = seatOf(player)
	if action.type == "start" and G.phase == "lobby" then
		if seat ~= 1 then return end   -- only the host (first seat) launches
		startGame({
			mode = action.mode == "bomb" and "bomb" or "race",
			subject = (type(action.subject) == "string" and Banks[action.subject]) and action.subject or "h2",
			rounds = pick(Config.ROUNDS, action.rounds, 10),
			lives = pick(Config.LIVES, action.lives, 2),
			fuse = pick(Config.FUSES, action.fuse, 30),
		})
	elseif action.type == "answer" and G.phase == "question" and seat then
		local c = action.c
		if type(c) ~= "number" or c % 1 ~= 0 or c < 1 or c > 4 then return end
		if G.answers[player.UserId] then return end
		if workspace:GetServerTimeNow() > G.deadline + 0.5 then return end
		if G.mode == "bomb" and seat ~= G.turn then return end
		G.answers[player.UserId] = { c = c, t = os.clock() }
		if G.mode == "bomb" or c == G.question.correct then
			resolve()   -- Race: the first correct answer the server receives takes the point
		else
			local all = true
			for _, s in ipairs(G.seats) do
				if present(s) and not G.answers[s.userId] then all = false end
			end
			if all then resolve() else broadcast() end
		end
	elseif action.type == "ready" and G.phase == "reveal" and G.mode == "race" and seat then
		G.ready[player.UserId] = true
		local all = true
		for _, s in ipairs(G.seats) do
			if present(s) and not G.ready[s.userId] then all = false end
		end
		if all then advance() else broadcast() end
	elseif action.type == "lobby" and G.phase == "ended" then
		G.token = G.token + 1
		G.phase = "lobby"
		G.question = nil
		G.message = ""
		refreshLobbySeats()
		broadcast()
	elseif action.type == "hello" then
		StateEvent:FireClient(player, publicState())
	end
end)

Players.PlayerAdded:Connect(function(player)
	loadProfile(player)
	player.CharacterAdded:Connect(function()
		if G.phase ~= "lobby" and G.phase ~= "ended" and seatOf(player) then
			task.wait(0.5)
			holdCrew(true)
		end
	end)
	if G.phase == "lobby" then
		refreshLobbySeats()
		broadcast()
	end
end)

Players.PlayerRemoving:Connect(function(player)
	task.spawn(saveProfile, player.UserId)
	local seat = seatOf(player)
	if not seat then return end
	if G.phase == "lobby" then
		table.remove(G.seats, seat)
		broadcast()
	elseif G.phase == "question" or G.phase == "reveal" or G.phase == "countdown" then
		G.seats[seat].livesLeft = 0
		task.defer(function()
			if presentCount() < 2 and not (Config.ALLOW_SOLO_IN_STUDIO and RunService:IsStudio()) then
				endGame(true)
			elseif G.phase == "question" and G.mode == "bomb" and G.turn == seat then
				resolve()
			else
				broadcast()
			end
		end)
	end
end)

game:BindToClose(function()
	for _, p in ipairs(Players:GetPlayers()) do
		saveProfile(p.UserId)
	end
end)

for _, p in ipairs(Players:GetPlayers()) do
	loadProfile(p)
end
refreshLobbySeats()
