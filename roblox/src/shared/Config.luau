-- Shared settings for Paper One Duel: Orbit Station. Server and client both read this.
local Config = {}

Config.MAX_PLAYERS = 8
Config.RACE_TIME = 60          -- seconds per question in Race
Config.COUNTDOWN = 3
Config.REVEAL_MAX = 20         -- Race: seconds before the next question if not everyone presses Next
Config.ROUNDS = { 5, 10, 15 }
Config.LIVES = { 1, 2, 3 }
Config.FUSES = { 20, 30, 45, 60 }
Config.ALLOW_SOLO_IN_STUDIO = true   -- lets you test alone in Studio; live servers still need 2 players

Config.DATASTORE = "PaperOneDuel_v1"

-- The station deck: crew stand on pads around the reactor ring.
Config.CENTER = Vector3.new(0, 40, 0)   -- floats above the baseplate, out in space
Config.SEAT_RADIUS = 12

-- Orbit Station palette (matches the website).
Config.COLORS = {
	space = Color3.fromRGB(11, 14, 36),
	panel = Color3.fromRGB(22, 27, 61),
	ink = Color3.fromRGB(232, 236, 255),
	muted = Color3.fromRGB(140, 150, 196),
	core = Color3.fromRGB(255, 122, 69),
	accent = Color3.fromRGB(94, 234, 212),
	good = Color3.fromRGB(124, 230, 120),
	bad = Color3.fromRGB(255, 92, 122),
}
Config.SEAT_COLORS = {
	Color3.fromRGB(94, 234, 212), Color3.fromRGB(255, 209, 102), Color3.fromRGB(255, 122, 69), Color3.fromRGB(196, 155, 245),
	Color3.fromRGB(124, 230, 120), Color3.fromRGB(255, 92, 122), Color3.fromRGB(120, 170, 255), Color3.fromRGB(230, 230, 240),
}

return Config
