-- Paper One Duel: Orbit Station. Client: draws the HUD from the server's state and sends answers.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local StateEvent = remotes:WaitForChild("State")
local ActionEvent = remotes:WaitForChild("Action")
local player = Players.LocalPlayer
local C = Config.COLORS
local LETTERS = { "A", "B", "C", "D" }

local function new(className, props, children)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then inst[k] = v end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if props and props.Parent then inst.Parent = props.Parent end
	return inst
end
local function pixelBorder(color, thickness)
	return new("UIStroke", { Color = color, Thickness = thickness or 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, LineJoinMode = Enum.LineJoinMode.Miter })
end
local function label(props)
	props.BackgroundTransparency = 1
	props.TextColor3 = props.TextColor3 or C.ink
	props.Font = props.Font or Enum.Font.Gotham
	props.TextSize = props.TextSize or 18
	props.TextWrapped = true
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	return new("TextLabel", props)
end
local function button(text, color, props)
	props = props or {}
	props.Text = text
	props.BackgroundColor3 = color or C.panel
	props.TextColor3 = props.TextColor3 or C.ink
	props.Font = props.Font or Enum.Font.Arcade
	props.TextSize = props.TextSize or 20
	props.AutoButtonColor = true
	props.BorderSizePixel = 0
	local b = new("TextButton", props, { pixelBorder(C.ink, 2) })
	return b
end

-- Layout -------------------------------------------------------------------
local gui = new("ScreenGui", { Name = "OrbitHUD", ResetOnSpawn = false, IgnoreGuiInset = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = player:WaitForChild("PlayerGui") })

local panel = new("Frame", {
	Name = "Panel", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -12), Size = UDim2.new(0.94, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.space, BackgroundTransparency = 0.05, BorderSizePixel = 0, Parent = gui,
}, {
	pixelBorder(C.accent, 3),
	new("UISizeConstraint", { MaxSize = Vector2.new(760, 1000) }),
	new("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }),
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
})
local header = label({ Name = "Header", LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.Arcade, TextSize = 20, TextColor3 = C.accent, Text = "ORBIT STATION", Parent = panel })
local timerBack = new("Frame", { Name = "Timer", LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 8), BackgroundColor3 = C.panel, BorderSizePixel = 0, Parent = panel })
local timerFill = new("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = C.core, BorderSizePixel = 0, Parent = timerBack })
local status = label({ Name = "Status", LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Arcade, TextSize = 22, Text = "", Parent = panel })
local qText = label({ Name = "Question", LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextSize = 19, Text = "", Parent = panel })
local optFrame = new("Frame", { Name = "Options", LayoutOrder = 5, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = panel }, {
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
})
local optButtons = {}
for i = 1, 4 do
	local b = button("", C.panel, { LayoutOrder = i, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, TextSize = 18, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = optFrame })
	new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = b })
	b.MouseButton1Click:Connect(function()
		ActionEvent:FireServer({ type = "answer", c = i })
	end)
	optButtons[i] = b
end
local explain = label({ Name = "Explain", LayoutOrder = 6, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextSize = 16, TextColor3 = C.good, Text = "", Parent = panel })
local controls = new("Frame", { Name = "Controls", LayoutOrder = 7, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = panel }, {
	new("UIGridLayout", { CellSize = UDim2.new(0.32, 0, 0, 40), CellPadding = UDim2.new(0.02, 0, 0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
})

-- Crew list (top right)
local crew = new("Frame", {
	Name = "Crew", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12), Size = UDim2.new(0, 220, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundColor3 = C.space, BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = gui,
}, {
	pixelBorder(C.accent, 2),
	new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
	new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
})

-- Lobby choices (host only) --------------------------------------------------
local choice = { mode = "race", subject = "h2", rounds = 10, lives = 2, fuse = 30 }
local function cycle(list, value)
	for i, v in ipairs(list) do
		if v == value then return list[i % #list + 1] end
	end
	return list[1]
end

local state = nil
local function clearControls()
	for _, ch in ipairs(controls:GetChildren()) do
		if ch:IsA("GuiButton") or ch:IsA("TextLabel") then ch:Destroy() end
	end
end
local function addControl(text, color, onClick, order)
	local b = button(text, color, { LayoutOrder = order, TextSize = 16, Parent = controls })
	if onClick then b.MouseButton1Click:Connect(onClick) end
	return b
end

local render
local function renderCrew(st)
	for _, ch in ipairs(crew:GetChildren()) do
		if ch:IsA("TextLabel") then ch:Destroy() end
	end
	label({ LayoutOrder = 0, Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.Arcade, TextSize = 16, TextColor3 = C.accent, Text = "CREW " .. #st.seats .. "/" .. Config.MAX_PLAYERS, Parent = crew })
	for i, s in ipairs(st.seats) do
		local bits = {}
		if st.mode == "bomb" and st.phase ~= "lobby" then
			table.insert(bits, string.rep("♥", math.max(0, s.livesLeft)) .. string.rep("♡", math.max(0, st.lives - s.livesLeft)))
		elseif st.phase ~= "lobby" then
			table.insert(bits, s.score .. " pt")
		end
		if st.phase == "question" and s.answered then table.insert(bits, "locked") end
		if st.mode == "bomb" and st.phase == "question" and st.turn == i then table.insert(bits, "HAS THE CORE") end
		if not s.present then table.insert(bits, "left") end
		local you = s.userId == player.UserId and " (you)" or ""
		label({ LayoutOrder = i, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextSize = 15,
			TextColor3 = Config.SEAT_COLORS[(i - 1) % #Config.SEAT_COLORS + 1],
			Text = s.name .. you .. (#bits > 0 and ("  ·  " .. table.concat(bits, " · ")) or ""), Parent = crew })
	end
end

render = function()
	local st = state
	if not st then return end
	renderCrew(st)
	clearControls()
	local mySeat = nil
	for i, s in ipairs(st.seats) do
		if s.userId == player.UserId then mySeat = i end
	end
	local isHost = st.hostId == player.UserId
	local modeName = st.mode == "bomb" and "HOT CORE" or "RACE"
	header.Text = "ORBIT STATION · " .. (st.phase == "lobby" and "DOCKING BAY" or (st.subjectName .. " · " .. modeName))
	qText.Text = ""
	explain.Text = ""
	for _, b in ipairs(optButtons) do
		b.Visible = false
	end
	timerBack.Visible = st.phase == "question" or st.phase == "countdown"

	if st.phase == "lobby" then
		if isHost then
			status.Text = "You're the captain. Pick a mission and launch."
			local subjName = choice.subject
			for _, s in ipairs(st.subjects) do
				if s.key == choice.subject then subjName = s.name end
			end
			addControl("SUBJECT: " .. subjName, C.panel, function()
				local keys = {}
				for _, s in ipairs(st.subjects) do table.insert(keys, s.key) end
				choice.subject = cycle(keys, choice.subject); render()
			end, 1)
			addControl("MODE: " .. (choice.mode == "bomb" and "HOT CORE" or "RACE"), C.panel, function()
				choice.mode = choice.mode == "race" and "bomb" or "race"; render()
			end, 2)
			if choice.mode == "race" then
				addControl("LENGTH: " .. choice.rounds, C.panel, function() choice.rounds = cycle(Config.ROUNDS, choice.rounds); render() end, 3)
			else
				addControl("LIVES: " .. choice.lives, C.panel, function() choice.lives = cycle(Config.LIVES, choice.lives); render() end, 3)
				addControl("FUSE: " .. choice.fuse .. "s", C.panel, function() choice.fuse = cycle(Config.FUSES, choice.fuse); render() end, 4)
			end
			addControl("LAUNCH", C.core, function()
				ActionEvent:FireServer({ type = "start", mode = choice.mode, subject = choice.subject, rounds = choice.rounds, lives = choice.lives, fuse = choice.fuse })
			end, 9)
		else
			local host = st.seats[1] and st.seats[1].name or "the captain"
			status.Text = "Waiting for " .. host .. " to launch…"
		end
		qText.Text = st.message ~= "" and st.message or "Race: first correct answer scores. Hot Core: answer before the fuse runs out or the core blows and you lose a life."
	elseif st.phase == "countdown" then
		status.Text = "LAUNCHING…"
		qText.Text = st.mode == "bomb" and ((st.seats[st.turn] and st.seats[st.turn].name or "Someone") .. " starts with the core.") or "First correct answer scores."
	elseif st.phase == "question" or st.phase == "reveal" then
		local q = st.question
		local holding = st.mode == "bomb" and st.turn == mySeat
		local me = mySeat and st.seats[mySeat]
		if st.phase == "question" then
			if st.mode == "race" then
				status.Text = "Q" .. st.k .. "/" .. st.n .. (me and me.answered and "  ·  LOCKED IN" or "")
			else
				status.Text = holding and "YOU HAVE THE CORE! ANSWER FAST!" or ((st.seats[st.turn] and st.seats[st.turn].name or "Someone") .. " has the core")
			end
			status.TextColor3 = holding and C.core or C.ink
		else
			local r = st.result or {}
			if st.mode == "race" then
				if r.winner and r.winner > 0 then
					status.Text = (r.winner == mySeat and "YOU" or st.seats[r.winner].name) .. " took the point"
				else
					status.Text = "Nobody scored"
				end
				status.TextColor3 = r.winner == mySeat and C.good or C.ink
			else
				local who = r.seat == mySeat and "You" or (st.seats[r.seat] and st.seats[r.seat].name or "Someone")
				status.Text = r.ok and (who .. " got it. The core moves on.") or ("BOOM! " .. who .. (r.pick == 0 and " ran out of time." or " picked wrong."))
				status.TextColor3 = r.ok and C.good or C.bad
			end
		end
		qText.Text = "[" .. q.id .. " · " .. q.topic .. "]\n" .. q.q
		for i, b in ipairs(optButtons) do
			b.Visible = true
			b.Text = LETTERS[i] .. "   " .. q.options[i]
			b.BackgroundColor3 = C.panel
			local canAnswer = st.phase == "question" and mySeat ~= nil and not (me and me.answered) and (st.mode == "race" or holding)
			b.Active = canAnswer
			b.AutoButtonColor = canAnswer
			if st.phase == "reveal" then
				local r = st.result or {}
				local myPick = st.mode == "race" and (r.picks and mySeat and r.picks[mySeat] or 0) or (r.seat == mySeat and r.pick or 0)
				if i == q.correct then
					b.BackgroundColor3 = Color3.fromRGB(30, 90, 50)
				elseif i == myPick then
					b.BackgroundColor3 = Color3.fromRGB(110, 30, 50)
				end
			end
		end
		if st.phase == "reveal" then
			explain.Text = "Answer " .. LETTERS[q.correct] .. ". " .. (q.x or "")
			if st.mode == "race" and mySeat then
				local me2 = st.seats[mySeat]
				if me2 and not me2.ready then
					addControl(st.k < st.n and "NEXT" or "RESULTS", C.accent, function() ActionEvent:FireServer({ type = "ready" }) end, 1)
				else
					addControl("WAITING…", C.panel, nil, 1)
				end
			end
		end
	elseif st.phase == "ended" then
		status.Text = "MISSION OVER"
		status.TextColor3 = C.accent
		local lines = { st.message }
		for i, s in ipairs(st.seats) do
			local won = table.find(st.winners, i) ~= nil
			table.insert(lines, (won and "★ " or "   ") .. s.name .. (st.mode == "race" and ("  " .. s.score .. " pt") or (won and "  survived" or "  out")))
		end
		qText.Text = table.concat(lines, "\n")
		addControl("BACK TO BAY", C.accent, function() ActionEvent:FireServer({ type = "lobby" }) end, 1)
	end
end

StateEvent.OnClientEvent:Connect(function(st)
	state = st
	render()
end)
ActionEvent:FireServer({ type = "hello" })

-- Timer bar
RunService.RenderStepped:Connect(function()
	local st = state
	if not st or not timerBack.Visible then return end
	local total = st.phase == "countdown" and Config.COUNTDOWN or (st.mode == "race" and Config.RACE_TIME or st.fuse)
	local left = math.max(0, st.deadline - workspace:GetServerTimeNow())
	timerFill.Size = UDim2.new(math.clamp(left / total, 0, 1), 0, 1, 0)
	timerFill.BackgroundColor3 = (left < 6 and st.mode == "bomb") and C.bad or C.core
end)
