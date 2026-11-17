--// Apple Hub Plus v9  |  Add-on do Apple Hub (visual + Editor de Temas + Blox Fruits)
--// Execute este arquivo. Com AUTO_LOAD_HUB = true ele carrega o Apple Hub sozinho.
local AUTO_LOAD_HUB = true
local HUB_URL = "https://raw.githubusercontent.com/AppleHubScripts/Apple-Hub/refs/heads/main/Apple%20Hub"

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CS = game:GetService("CollectionService")
local RepStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer

local alive = true
local conns = {}
local function conn(c) conns[#conns + 1] = c return c end
local function loop(dt, fn) task.spawn(function() while alive do task.wait(dt) pcall(fn) end end) end

------------------------------------------------------------------
-- LOCALIZA O HUB
------------------------------------------------------------------
local function hubParent()
	local ok, h = pcall(function() return gethui() end)
	return (ok and h) or CoreGui
end
if getgenv and getgenv().ApplePlusUnload then pcall(getgenv().ApplePlusUnload) end
local function findHub() return hubParent():FindFirstChild("AppleHub") or CoreGui:FindFirstChild("AppleHub") end

local hub = findHub()
if not hub and AUTO_LOAD_HUB then
	local ok, err = pcall(function() loadstring(game:HttpGet(HUB_URL))() end)
	if not ok then warn("[Apple Plus] falha ao carregar o hub: " .. tostring(err)) end
end
local t0 = tick()
while not hub and tick() - t0 < 15 do task.wait(0.2) hub = findHub() end
if not hub then warn("[Apple Plus] Apple Hub não encontrado") return end
local main = hub:WaitForChild("Main", 10)
if not main then return end
task.wait(0.3)

local uiscale = main:FindFirstChildOfClass("UIScale")
local top, side, content, topLine
for _, c in ipairs(main:GetChildren()) do
	if c:IsA("Frame") then
		if c.Size.Y.Offset == 3 and c.Size.X.Scale == 1 then topLine = c
		elseif c.Size.Y.Offset == 40 and c.Size.X.Scale == 1 then top = c
		elseif c.Size.X.Offset == 128 then side = c
		elseif c.ClipsDescendants then content = c end
	end
end
if not (top and side and content and topLine) then warn("[Apple Plus] estrutura do hub mudou") return end

local titleLabel
for _, c in ipairs(top:GetChildren()) do
	if c:IsA("TextLabel") and c.Size.X.Scale == 1 then titleLabel = c end
end
local origBubble
for _, c in ipairs(hub:GetChildren()) do
	if c:IsA("TextButton") and c.Size.X.Offset == 52 then origBubble = c end
end
local indicator
for _, c in ipairs(side:GetChildren()) do
	if c:IsA("Frame") and c.Size.Y.Offset == 32 and c:FindFirstChildOfClass("UIGradient") then indicator = c end
end
local tabBtns = {}
for _, b in ipairs(side:GetChildren()) do
	if b:IsA("TextButton") then
		local icon, nm = b.Text:match("^(.-)%s%s(%a+)$")
		if nm then tabBtns[#tabBtns + 1] = {b = b, icon = icon, name = nm, text = b.Text, size = b.TextSize, font = b.Font} end
	end
end

------------------------------------------------------------------
-- CONFIG
------------------------------------------------------------------
local FILE = "AppleHubPlus.json"
local C = {
	Profile = "", PaletteSel = "", ThemeName = "Meu tema",
	-- cores custom (HSV)
	CAh = 210, CAs = 80, CAv = 100, CBh = 280, CBs = 70, CBv = 100,
	-- partículas
	Snow = true, SnowFront = true, SnowFull = false, SnowCount = 40, SnowSpeed = 45, SnowSize = 14, SnowWind = 18, SnowAlpha = 30,
	SnowShape = "Bolinha", SnowColor = "Branco", SnowDir = "Cair", SnowSpin = true, SnowSizeVar = true, SnowTwinkle = true,
	-- painel
	Neon = true, NeonThick = 2, NeonSpeed = 60, NeonMode = "Tema",
	Gradient = true, GradPreset = "Tema", GradAlpha = 88, GradSpeed = 25,
	LineThick = 3, LineMode = "Padrão", TitleSize = 13, TitleMode = "Padrão", SideAlpha = 20, RowAlpha = 20,
	Ripple = true, RippleColor = "Tema",
	-- botão
	Btn = true, HideBubble = true, BtnSize = 56, BtnShape = "Círculo", BtnStyle = "Neon", BtnColor = "Tema", BtnIcon = "A",
	BtnPulse = true, BtnSpin = true, BtnX = 0.06, BtnY = 0.4,
	-- abas
	TabSize = 13, TabFont = "GothamBold", TabCaps = false, TabHover = true, TabIndR = 11, TabIndAlpha = 0, TabIndGlow = true,
	-- intro
	Intro = true, IntroStyle = "Letras", IntroText = "APPLE HUB", IntroSub = "Blox Fruits  •  Plus Edition", IntroColor = "Tema",
	IntroBg = "Gradiente", IntroTime = 38, IntroBar = true, IntroSkip = true,
	-- blox
	FruitNotify = true, BossNotify = true, MirageNotify = true, MoonNotify = true,
	AutoFruitBuy = false, FruitBuyDelay = 30, AutoBerry = false, AutoRace = false, TravelSpeed = 300,
}
local NOSAVE = {AutoFruitBuy = true, AutoBerry = true, AutoRace = true}
local LIM = {
	SnowCount = {5, 120}, SnowSpeed = {5, 200}, SnowSize = {6, 40}, SnowWind = {-60, 60}, SnowAlpha = {0, 90},
	NeonThick = {1, 6}, NeonSpeed = {0, 200}, GradAlpha = {40, 100}, GradSpeed = {0, 120}, LineThick = {1, 8},
	TitleSize = {10, 24}, SideAlpha = {0, 90}, RowAlpha = {0, 90}, BtnSize = {36, 90}, TabSize = {10, 18},
	TabIndR = {0, 20}, TabIndAlpha = {0, 80}, IntroTime = {20, 80}, FruitBuyDelay = {10, 120}, TravelSpeed = {100, 600},
	CAh = {0, 360}, CAs = {0, 100}, CAv = {0, 100}, CBh = {0, 360}, CBs = {0, 100}, CBv = {0, 100},
}
local function sanitize(k, v)
	if type(v) == "number" then
		local l = LIM[k]
		if l then v = math.clamp(math.floor(v), l[1], l[2]) else v = math.clamp(v, -1000, 1000) end
	elseif type(v) == "string" then
		v = v:sub(1, 80)
	end
	return v
end
pcall(function()
	if isfile and isfile(FILE) then
		local d = HttpService:JSONDecode(readfile(FILE))
		for k, v in pairs(d) do if C[k] ~= nil and type(v) == type(C[k]) then C[k] = sanitize(k, v) end end
	end
end)

------------------------------------------------------------------
-- HELPERS + PALETA
------------------------------------------------------------------
local function new(class, props, kids)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do if k ~= "Parent" then o[k] = v end end
	for _, k in ipairs(kids or {}) do k.Parent = o end
	if props and props.Parent then o.Parent = props.Parent end
	return o
end
local function rc(o, r) return new("UICorner", {CornerRadius = UDim.new(0, r), Parent = o}) end
local function tween(o, t, p, s, d)
	pcall(function() TS:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quint, d or Enum.EasingDirection.Out), p):Play() end)
end
local function commas(n)
	local s = tostring(math.floor(tonumber(n) or 0))
	local out = s:reverse():gsub("(%d%d%d)", "%1."):reverse()
	return (out:gsub("^%.", ""))
end

local P, rowSrc = {}, nil
local function readPalette()
	local bg = main.BackgroundColor3
	local sd = side.BackgroundColor3
	if not (rowSrc and rowSrc.Parent) then
		local s = content:FindFirstChildWhichIsA("UIStroke", true)
		if s and s.Parent:IsA("Frame") and s.Parent.Size.Y.Offset >= 30 then rowSrc = s.Parent end
	end
	local rowc = rowSrc and rowSrc.BackgroundColor3 or sd
	local light = (0.299 * bg.R + 0.587 * bg.G + 0.114 * bg.B) > 0.5
	local txt = light and Color3.fromRGB(28, 28, 30) or Color3.fromRGB(245, 245, 247)
	local a1, a2 = Color3.fromRGB(10, 132, 255), Color3.fromRGB(94, 92, 230)
	local g = (indicator and indicator:FindFirstChildOfClass("UIGradient")) or topLine:FindFirstChildOfClass("UIGradient")
	if g then local k = g.Color.Keypoints a1, a2 = k[1].Value, k[#k].Value end
	P = {bg = bg, side = sd, row = rowc, text = txt, sub = txt:Lerp(bg, 0.45), acc = a1, acc2 = a2}
end
readPalette()

local binds = {}
local function bind(o, prop, fn)
	local f
	f = function()
		if o.Parent == nil then binds[f] = nil return end
		pcall(function() o[prop] = fn() end)
	end
	binds[f] = true
	f()
	return f
end
local applyPanel, applyBtn
local lastSig = ""
local function refreshPalette(force)
	readPalette()
	local sig = P.bg:ToHex() .. P.acc:ToHex() .. P.acc2:ToHex() .. P.row:ToHex()
	if force or sig ~= lastSig then
		lastSig = sig
		for f in pairs(binds) do f() end
		if applyPanel then applyPanel() end
		if applyBtn then applyBtn() end
	end
end

local hueT = 0
local function hsv(h) return Color3.fromHSV(h % 1, 0.65, 1) end
local function customA() return Color3.fromHSV(C.CAh / 360, C.CAs / 100, C.CAv / 100) end
local function customB() return Color3.fromHSV(C.CBh / 360, C.CBs / 100, C.CBv / 100) end
local PresetColors = {Branco = Color3.new(1, 1, 1), Rosa = Color3.fromRGB(255, 130, 200), Dourado = Color3.fromRGB(255, 208, 80),
	Ciano = Color3.fromRGB(110, 230, 255), ["Lilás"] = Color3.fromRGB(190, 150, 255), Verde = Color3.fromRGB(110, 255, 160)}
local ColorModes = {"Tema", "Custom", "Branco", "Arco-íris", "Rosa", "Dourado", "Ciano", "Lilás", "Verde"}
local RAINBOW
do
	local k = {}
	for i = 0, 6 do k[#k + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i % 6) / 6, 0.7, 1)) end
	RAINBOW = ColorSequence.new(k)
end
local function modeSeq(mode)
	if mode == "Tema" then
		return ColorSequence.new({ColorSequenceKeypoint.new(0, P.acc), ColorSequenceKeypoint.new(0.5, P.acc2), ColorSequenceKeypoint.new(1, P.acc)})
	elseif mode == "Custom" then
		local a, b = customA(), customB()
		return ColorSequence.new({ColorSequenceKeypoint.new(0, a), ColorSequenceKeypoint.new(0.5, b), ColorSequenceKeypoint.new(1, a)})
	elseif mode == "Arco-íris" then return RAINBOW end
	return ColorSequence.new(PresetColors[mode] or Color3.new(1, 1, 1))
end
local function modeColor(mode, off)
	off = off or 0
	if mode == "Tema" then return P.acc:Lerp(P.acc2, off % 1)
	elseif mode == "Custom" then return customA():Lerp(customB(), off % 1)
	elseif mode == "Arco-íris" then return hsv(hueT + off) end
	return PresetColors[mode] or Color3.new(1, 1, 1)
end
local GradPresets = {
	["Pôr do sol"] = {Color3.fromRGB(255, 125, 70), Color3.fromRGB(255, 50, 100)},
	Oceano = {Color3.fromRGB(0, 200, 255), Color3.fromRGB(0, 110, 255)},
	Neon = {Color3.fromRGB(57, 255, 20), Color3.fromRGB(0, 229, 255)},
	Aurora = {Color3.fromRGB(52, 230, 160), Color3.fromRGB(90, 120, 255)},
}
local function gradPreset(n)
	if n == "Tema" then return ColorSequence.new(P.acc, P.acc2) end
	if n == "Custom" then return ColorSequence.new(customA(), customB()) end
	if n == "Arco-íris" then return RAINBOW end
	local g = GradPresets[n] or {P.acc, P.acc2}
	return ColorSequence.new(g[1], g[2])
end

------------------------------------------------------------------
-- GUI PRÓPRIA + AVISOS
------------------------------------------------------------------
pcall(function() local o = hubParent():FindFirstChild("AppleHubPlus") if o then o:Destroy() end end)
local gui = new("ScreenGui", {Name = "AppleHubPlus", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 50,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = hubParent()})

local toastHolder = new("Frame", {Size = UDim2.new(0, 280, 1, -20), Position = UDim2.new(0.5, -140, 0, 10), BackgroundTransparency = 1, ZIndex = 150, Parent = gui},
	{new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})})
local function toast(title, msg, dur)
	local f = new("CanvasGroup", {Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = P.side, GroupTransparency = 1, Parent = toastHolder})
	rc(f, 12)
	new("Frame", {Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = P.acc, BorderSizePixel = 0, Parent = f})
	new("TextLabel", {Size = UDim2.new(1, -20, 0, 20), Position = UDim2.fromOffset(14, 5), BackgroundTransparency = 1, Text = title, Font = Enum.Font.GothamBold,
		TextSize = 13, TextColor3 = P.text, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
	new("TextLabel", {Size = UDim2.new(1, -20, 0, 18), Position = UDim2.fromOffset(14, 25), BackgroundTransparency = 1, Text = msg, Font = Enum.Font.Gotham,
		TextSize = 12, TextColor3 = P.sub, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = f})
	tween(f, 0.3, {GroupTransparency = 0})
	task.delay(dur or 3, function() tween(f, 0.3, {GroupTransparency = 1}) task.wait(0.35) pcall(function() f:Destroy() end) end)
end

------------------------------------------------------------------
-- PARTÍCULAS
------------------------------------------------------------------
local GLYPH = {Bolinha = "●", Estrela = "✦", Flor = "✿", ["Coração"] = "♥", Diamante = "◆", Floco = "❄", ["Maçã"] = "🍎"}
local ShapeNames = {"Bolinha", "Estrela", "Flor", "Coração", "Diamante", "Floco", "Maçã"}
local snowLayer = new("Frame", {Name = "Snow", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 10, Parent = main})
local flakes, snowFull = {}, false
local function spawnFlake(i)
	local f = {x = math.random(), y = math.random(), k = 0.6 + math.random() * 0.8, s = 0.6 + math.random() * 0.8,
		ph = math.random() * 6.28, r = math.random() * 360, rs = (math.random() - 0.5) * 90}
	f.l = new("TextLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(40, 40), BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold, Text = "●", TextSize = 14, Parent = snowLayer})
	flakes[i] = f
end
local function updateSnow(dt)
	if C.SnowFull ~= snowFull then snowFull = C.SnowFull snowLayer.Parent = snowFull and gui or main end
	snowLayer.ZIndex = C.SnowFront and 10 or 0
	snowLayer.Visible = C.Snow
	if not C.Snow then return end
	if not C.SnowFull and not main.Visible then return end
	dt = math.min(dt, 0.1)
	while #flakes < C.SnowCount do spawnFlake(#flakes + 1) end
	while #flakes > C.SnowCount do table.remove(flakes).l:Destroy() end
	local h, w = math.max(snowLayer.AbsoluteSize.Y, 120), math.max(snowLayer.AbsoluteSize.X, 120)
	local dir = C.SnowDir == "Cair" and 1 or -1
	local g, n = GLYPH[C.SnowShape] or "●", #flakes
	for i, f in ipairs(flakes) do
		f.y = f.y + dir * (C.SnowSpeed * f.k / h) * dt
		f.ph = f.ph + dt * (0.8 + f.k)
		f.x = f.x + (C.SnowWind / w + math.sin(f.ph) * 0.03) * dt
		if f.y > 1.06 then f.y = -0.06 f.x = math.random() elseif f.y < -0.06 then f.y = 1.06 f.x = math.random() end
		if f.x > 1.06 then f.x = -0.06 elseif f.x < -0.06 then f.x = 1.06 end
		if C.SnowSpin then f.r = f.r + f.rs * dt end
		local l = f.l
		local a = C.SnowAlpha / 100
		if C.SnowTwinkle then a = math.clamp(a + 0.25 * math.sin(f.ph * 3), 0, 0.95) end
		l.Position = UDim2.fromScale(f.x, f.y)
		l.Rotation = f.r
		l.TextSize = math.floor(C.SnowSize * (C.SnowSizeVar and f.s or 1))
		l.TextTransparency = a
		l.TextColor3 = modeColor(C.SnowColor, i / n)
		if l.Text ~= g then l.Text = g end
	end
end

------------------------------------------------------------------
-- PAINEL
------------------------------------------------------------------
local neon = new("UIStroke", {Thickness = 2, Color = Color3.new(1, 1, 1), ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = main})
local neonG = new("UIGradient", {Parent = neon})
local over = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.88, BorderSizePixel = 0, ZIndex = 0, Parent = main})
local overG = new("UIGradient", {Rotation = 35, Parent = over})
local myLine = new("Frame", {Size = UDim2.new(1, 0, 0, 3), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 6, Visible = false, Parent = main})
local lineG = new("UIGradient", {Parent = myLine})
local rippleLayer = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 12, Parent = main})

local dirty = {rows = true}
local lastTitleMode = "Padrão"
applyPanel = function()
	neon.Enabled = C.Neon
	neon.Thickness = C.NeonThick
	neonG.Color = modeSeq(C.NeonMode)
	over.Visible = C.Gradient
	over.BackgroundTransparency = C.GradAlpha / 100
	overG.Color = gradPreset(C.GradPreset)
	topLine.Size = UDim2.new(1, 0, 0, C.LineThick)
	myLine.Size = UDim2.new(1, 0, 0, C.LineThick)
	myLine.Visible = C.LineMode ~= "Padrão"
	lineG.Color = modeSeq(C.LineMode == "Padrão" and "Tema" or C.LineMode)
	if titleLabel then
		titleLabel.TextSize = C.TitleSize
		if C.TitleMode ~= lastTitleMode then
			lastTitleMode = C.TitleMode
			if C.TitleMode == "Padrão" then titleLabel.TextColor3 = P.sub end
		end
	end
	side.BackgroundTransparency = C.SideAlpha / 100
	dirty.rows = true
end
local function applyRows()
	for _, d in ipairs(content:GetDescendants()) do
		if d:IsA("Frame") and d.Size.Y.Offset >= 30 and d:FindFirstChildOfClass("UIStroke") then d.BackgroundTransparency = C.RowAlpha / 100 end
	end
end

-- ondas ao tocar
conn(UIS.InputBegan:Connect(function(i)
	if not C.Ripple or not main.Visible then return end
	if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
	local p, s = main.AbsolutePosition, main.AbsoluteSize
	local x, y = i.Position.X - p.X, i.Position.Y - p.Y
	if x < 0 or y < 0 or x > s.X or y > s.Y then return end
	local sc = uiscale and uiscale.Scale or 1
	local f = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x / sc, y / sc), Size = UDim2.fromOffset(6, 6),
		BackgroundTransparency = 1, Parent = rippleLayer})
	new("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = f})
	local st = new("UIStroke", {Thickness = 2.5, Color = modeColor(C.RippleColor, 0), Transparency = 0.1, Parent = f})
	tween(f, 0.7, {Size = UDim2.fromOffset(110, 110)})
	tween(st, 0.7, {Transparency = 1})
	task.delay(0.75, function() pcall(function() f:Destroy() end) end)
end))

------------------------------------------------------------------
-- ABAS
------------------------------------------------------------------
local indCorner = indicator and indicator:FindFirstChildOfClass("UICorner")
local indStroke
if indicator then
	indStroke = new("UIStroke", {Thickness = 3, Transparency = 0.55, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = indicator})
	bind(indStroke, "Color", function() return P.acc end)
end
local function applyTabs()
	for _, t in ipairs(tabBtns) do
		t.b.TextSize = C.TabSize
		pcall(function() t.b.Font = Enum.Font[C.TabFont] end)
		t.b.Text = t.icon .. "  " .. (C.TabCaps and t.name:upper() or t.name)
	end
	if indicator then
		indicator.BackgroundTransparency = C.TabIndAlpha / 100
		if indCorner then indCorner.CornerRadius = UDim.new(0, C.TabIndR) end
		indStroke.Enabled = C.TabIndGlow
	end
end
for _, t in ipairs(tabBtns) do
	t.b.MouseEnter:Connect(function() if alive and C.TabHover then tween(t.b, 0.2, {TextSize = C.TabSize + 2}) end end)
	t.b.MouseLeave:Connect(function() if alive then tween(t.b, 0.2, {TextSize = C.TabSize}) end end)
	t.b.MouseButton1Click:Connect(function()
		if alive and C.TabHover then t.b.TextSize = C.TabSize + 5 tween(t.b, 0.35, {TextSize = C.TabSize}, Enum.EasingStyle.Back) end
	end)
end

------------------------------------------------------------------
-- BOTÃO FLUTUANTE
------------------------------------------------------------------
local btn = new("TextButton", {Name = "PlusBtn", Size = UDim2.fromOffset(56, 56), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(C.BtnX, C.BtnY),
	BackgroundColor3 = Color3.new(1, 1, 1), Text = "", AutoButtonColor = false, ZIndex = 30, Parent = gui})
local btnCorner = new("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = btn})
local btnScale = new("UIScale", {Parent = btn})
local btnG = new("UIGradient", {Rotation = 45, Parent = btn})
local ringStroke = new("UIStroke", {Thickness = 2.5, Color = Color3.new(1, 1, 1), Transparency = 0.15, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = btn})
local ringG = new("UIGradient", {Parent = ringStroke})
local pulse = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = btn})
local pulseCorner = new("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = pulse})
local pulseStroke = new("UIStroke", {Thickness = 3, Color = Color3.new(1, 1, 1), ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = pulse})
local pulseG = new("UIGradient", {Parent = pulseStroke})
local gloss = new("Frame", {Size = UDim2.new(1, -12, 0.45, 0), Position = UDim2.fromOffset(6, 3), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = btn},
	{new("UICorner", {CornerRadius = UDim.new(0.5, 0)}),
	 new("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1)})})})
local icon = new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "A", Font = Enum.Font.GothamBlack, TextSize = 26,
	TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.8, Parent = btn})
local SHAPE_R = {["Círculo"] = 0.5, Squircle = 0.3, Quadrado = 0.1, Diamante = 0.18}
applyBtn = function()
	btn.Visible = C.Btn
	local s = C.BtnSize
	btn.Size = UDim2.fromOffset(s, s)
	local r = SHAPE_R[C.BtnShape] or 0.5
	btnCorner.CornerRadius = UDim.new(r, 0)
	pulseCorner.CornerRadius = UDim.new(r, 0)
	btn.Rotation = C.BtnShape == "Diamante" and 45 or 0
	icon.Rotation = C.BtnShape == "Diamante" and -45 or 0
	icon.Text = C.BtnIcon ~= "" and C.BtnIcon or "A"
	icon.TextSize = math.floor(s * 0.46)
	local st = C.BtnStyle
	if st == "Vidro" then
		btnG.Enabled = false
		btn.BackgroundColor3 = P.bg
		btn.BackgroundTransparency = 0.2
		icon.TextColor3 = modeColor(C.BtnColor, 0)
	elseif st == "Sólido" then
		btnG.Enabled = false
		btn.BackgroundColor3 = modeColor(C.BtnColor, 0)
		btn.BackgroundTransparency = 0
		icon.TextColor3 = Color3.new(1, 1, 1)
	else
		btnG.Enabled = true
		btnG.Color = modeSeq(C.BtnColor)
		btn.BackgroundColor3 = Color3.new(1, 1, 1)
		btn.BackgroundTransparency = 0
		icon.TextColor3 = Color3.new(1, 1, 1)
	end
	gloss.Visible = st ~= "Vidro"
	ringStroke.Enabled = st ~= "Sólido"
	ringG.Color = (st == "Neon") and modeSeq("Branco") or modeSeq(C.BtnColor)
	pulseStroke.Enabled = C.BtnPulse
	pulseG.Color = modeSeq(C.BtnColor)
end

local function isShown() return main.Visible and main.GroupTransparency < 0.5 end
local baseScale = uiscale and uiscale.Scale or 1
local function toggleHub()
	if isShown() then
		tween(main, 0.25, {GroupTransparency = 1})
		if uiscale then tween(uiscale, 0.25, {Scale = baseScale * 0.9}) end
		task.delay(0.27, function() if main.GroupTransparency >= 0.99 then main.Visible = false end end)
	else
		main.Visible = true
		tween(main, 0.4, {GroupTransparency = 0})
		if uiscale then tween(uiscale, 0.5, {Scale = baseScale}, Enum.EasingStyle.Back) end
	end
end
if origBubble then
	conn(origBubble:GetPropertyChangedSignal("Visible"):Connect(function()
		if C.Btn and C.HideBubble and origBubble.Visible then origBubble.Visible = false end
	end))
end
local drag = {on = false, moved = false}
btn.MouseEnter:Connect(function() if not drag.on then tween(btnScale, 0.2, {Scale = 1.1}) end end)
btn.MouseLeave:Connect(function() if not drag.on then tween(btnScale, 0.2, {Scale = 1}) end end)
btn.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		drag.on, drag.moved, drag.start, drag.ox, drag.oy = true, false, i.Position, C.BtnX, C.BtnY
		tween(btnScale, 0.12, {Scale = 0.9})
	end
end)
conn(UIS.InputChanged:Connect(function(i)
	if drag.on and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - drag.start
		if d.Magnitude > 8 then drag.moved = true end
		if drag.moved then
			local vp = gui.AbsoluteSize
			C.BtnX = math.clamp(drag.ox + d.X / vp.X, 0.02, 0.98)
			C.BtnY = math.clamp(drag.oy + d.Y / vp.Y, 0.04, 0.96)
			btn.Position = UDim2.fromScale(C.BtnX, C.BtnY)
		end
	end
end))
conn(UIS.InputEnded:Connect(function(i)
	if drag.on and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
		drag.on = false
		tween(btnScale, 0.15, {Scale = 1})
		if not drag.moved then toggleHub() end
	end
end))

------------------------------------------------------------------
-- INTRO
------------------------------------------------------------------
local introBusy = false
local function playIntro()
	if introBusy then return end
	introBusy = true
	local ov
	local ok, err = pcall(function()
		local vp = gui.AbsoluteSize
		local skip = false
		local dur = math.max(C.IntroTime / 10, 1.5)
		ov = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, GroupTransparency = 1,
			Active = true, ZIndex = 200, Parent = gui})
		if C.IntroBg == "Tema" then ov.BackgroundColor3 = P.bg:Lerp(Color3.new(0, 0, 0), 0.3) end
		if C.IntroBg == "Gradiente" then
			local g = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.45, BorderSizePixel = 0, Parent = ov})
			new("UIGradient", {Rotation = 90, Color = ColorSequence.new(Color3.new(0, 0, 0), modeColor(C.IntroColor, 0.5)), Parent = g})
		end
		ov.InputBegan:Connect(function(i)
			if C.IntroSkip and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then skip = true end
		end)
		local col0 = modeColor(C.IntroColor, 0)
		local function ring(delay0, maxS)
			task.delay(delay0, function()
				if not ov or not ov.Parent then return end
				local f = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, Parent = ov})
				new("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = f})
				local s = new("UIStroke", {Thickness = 3, Color = col0, Transparency = 0.2, Parent = f})
				tween(f, 1.4, {Size = UDim2.fromOffset(maxS, maxS)})
				tween(s, 1.4, {Transparency = 1})
				task.delay(1.5, function() pcall(function() f:Destroy() end) end)
			end)
		end
		local mx = math.max(vp.X, vp.Y) * 1.2
		ring(0.2, mx * 0.5) ring(0.5, mx * 0.8) ring(0.8, mx)
		for i = 1, 26 do
			local a, rad = math.random() * 6.283, math.random(120, 380)
			local sp = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(6, 6),
				BackgroundColor3 = modeColor(C.IntroColor, i / 26), BorderSizePixel = 0, Parent = ov})
			new("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = sp})
			task.delay(0.3, function()
				tween(sp, 1.1, {Position = UDim2.new(0.5, math.cos(a) * rad, 0.46, math.sin(a) * rad), BackgroundTransparency = 1})
				task.delay(1.2, function() pcall(function() sp:Destroy() end) end)
			end)
		end

		local chars = {}
		local text = C.IntroText ~= "" and C.IntroText or "APPLE HUB"
		for _, cp in utf8.codes(text) do chars[#chars + 1] = utf8.char(cp) end
		local n = #chars
		local size = math.clamp(math.floor(vp.X * 0.82 / (math.max(n, 1) * 0.72)), 20, 56)
		local style = C.IntroStyle
		local holder = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.new(1, 0, 0, size + 20),
			BackgroundTransparency = 1, Parent = ov},
			{new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder})})
		local hs = new("UIScale", {Parent = holder})
		local labels = {}
		for i, ch in ipairs(chars) do
			labels[i] = new("TextLabel", {AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1,
				Text = ch == " " and "\u{00A0}" or ch, Font = (style == "Digitar") and Enum.Font.Code or Enum.Font.GothamBlack, TextSize = size,
				TextColor3 = modeColor(C.IntroColor, (i - 1) / math.max(n - 1, 1)), TextTransparency = 1, LayoutOrder = i, Parent = holder})
		end
		local cursor
		if style == "Digitar" then
			cursor = new("TextLabel", {AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, Text = "▌",
				Font = Enum.Font.Code, TextSize = size, TextColor3 = col0, LayoutOrder = n + 1, Parent = holder})
		end
		if style == "Letras" then
			for i, l in ipairs(labels) do
				l.TextSize = 4
				task.delay(0.35 + (i - 1) * 0.07, function() tween(l, 0.5, {TextSize = size, TextTransparency = 0}, Enum.EasingStyle.Back) end)
			end
		elseif style == "Zoom" then
			hs.Scale = 3
			task.delay(0.3, function()
				tween(hs, 1, {Scale = 1})
				for _, l in ipairs(labels) do tween(l, 0.8, {TextTransparency = 0}) end
			end)
		elseif style == "Portal" then
			hs.Scale = 0
			holder.Rotation = -180
			ring(1.1, mx * 0.6)
			task.delay(0.3, function()
				tween(hs, 1.1, {Scale = 1}, Enum.EasingStyle.Back)
				tween(holder, 1.1, {Rotation = 0})
				for _, l in ipairs(labels) do tween(l, 0.6, {TextTransparency = 0}) end
			end)
		elseif style == "Digitar" then
			for i, l in ipairs(labels) do task.delay(0.4 + (i - 1) * 0.09, function() l.TextTransparency = 0 end) end
		elseif style == "Glitch" then
			task.delay(0.3, function()
				for _, l in ipairs(labels) do l.TextTransparency = 0 end
				local e = os.clock() + 1.4
				while os.clock() < e and alive and not skip and ov.Parent do
					for i, l in ipairs(labels) do
						l.Rotation = math.random(-5, 5)
						l.TextColor3 = (math.random() < 0.4) and Color3.fromHSV(math.random(), 1, 1) or modeColor(C.IntroColor, (i - 1) / math.max(n - 1, 1))
					end
					holder.Position = UDim2.new(0.5, math.random(-6, 6), 0.46, math.random(-3, 3))
					task.wait(0.05)
				end
				holder.Position = UDim2.fromScale(0.5, 0.46)
				for i, l in ipairs(labels) do l.Rotation = 0 l.TextColor3 = modeColor(C.IntroColor, (i - 1) / math.max(n - 1, 1)) end
			end)
		end

		local sub = new("TextLabel", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.46, (size + 20) / 2 + 6), Size = UDim2.new(0.9, 0, 0, 22),
			BackgroundTransparency = 1, Text = C.IntroSub, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Color3.fromRGB(215, 215, 225),
			TextTransparency = 1, Parent = ov})
		task.delay(0.9 + math.min(n, 12) * 0.05, function() tween(sub, 0.6, {TextTransparency = 0.1}) end)

		local fill, pct
		if C.IntroBar then
			local bw = math.min(260, vp.X * 0.6)
			local barBg = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.72), Size = UDim2.fromOffset(bw, 5),
				BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.88, BorderSizePixel = 0, Parent = ov})
			rc(barBg, 3)
			fill = new("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = barBg})
			rc(fill, 3)
			new("UIGradient", {Color = modeSeq(C.IntroColor), Parent = fill})
			pct = new("TextLabel", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.72, 10), Size = UDim2.fromOffset(120, 18), BackgroundTransparency = 1,
				Text = "0%", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(200, 200, 215), Parent = ov})
		end

		tween(ov, 0.3, {GroupTransparency = 0})
		local ts = os.clock()
		while alive and not skip and os.clock() - ts < dur do
			local a = math.clamp((os.clock() - ts - 0.3) / math.max(dur - 0.9, 0.5), 0, 1)
			if fill then fill.Size = UDim2.fromScale(a, 1) pct.Text = math.floor(a * 100) .. "%" end
			if cursor then cursor.TextTransparency = (math.floor(os.clock() * 3) % 2 == 0) and 0 or 1 end
			task.wait(0.03)
		end
		if fill then fill.Size = UDim2.fromScale(1, 1) pct.Text = "100%" end
		tween(hs, 0.55, {Scale = hs.Scale * 1.12})
		tween(ov, 0.55, {GroupTransparency = 1})
		task.wait(0.6)
	end)
	if not ok then warn("[Apple Plus] intro: " .. tostring(err)) end
	pcall(function() ov:Destroy() end)
	introBusy = false
end

------------------------------------------------------------------
-- BLOX FRUITS (extras)
------------------------------------------------------------------
local function root() local c = lp.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function invoke(...)
	local args = table.pack(...)
	local rem = RepStorage:FindFirstChild("Remotes")
	local cf = rem and rem:FindFirstChild("CommF_")
	if not cf then return nil end
	local ok, res = pcall(function() return cf:InvokeServer(table.unpack(args, 1, args.n)) end)
	return ok and res or nil
end
local function goTo(pos, stopFn)
	local r = root()
	if not r then return end
	local d = (pos - r.Position).Magnitude
	if d < 60 then r.CFrame = CFrame.new(pos) return end
	local t = d / math.max(C.TravelSpeed, 50)
	local nc = RS.Stepped:Connect(function()
		local c = lp.Character
		if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
		r.AssemblyLinearVelocity = Vector3.zero
	end)
	local tw = TS:Create(r, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
	tw:Play()
	local s0 = tick()
	while alive and tick() - s0 < t + 0.2 do
		if stopFn and stopFn() then tw:Cancel() break end
		task.wait(0.05)
	end
	nc:Disconnect()
end

local lastBuy = 0
loop(1, function()
	if C.AutoFruitBuy and tick() - lastBuy >= C.FruitBuyDelay then
		lastBuy = tick()
		local r = invoke("Cousin", "Buy")
		toast("Fruta aleatória", r and tostring(r) or "Sem resposta do servidor", 2.5)
	end
end)
loop(5, function()
	if not C.AutoRace then return end
	local rem = RepStorage:FindFirstChild("Remotes")
	local ce = rem and rem:FindFirstChild("CommE")
	if ce then ce:FireServer("ActivateAbility") end
end)
task.spawn(function()
	while alive do
		task.wait(0.6)
		if C.AutoBerry then
			pcall(function()
				local r = root()
				if not r then return end
				local best, bd
				for _, b in ipairs(CS:GetTagged("BerryBush")) do
					if b.Parent then
						local d = (b:GetPivot().Position - r.Position).Magnitude
						if not bd or d < bd then best, bd = b, d end
					end
				end
				if best then
					goTo(best:GetPivot().Position + Vector3.new(0, 3, 0), function() return not C.AutoBerry end)
					for _, pp in ipairs(best:GetDescendants()) do
						if pp:IsA("ProximityPrompt") then pcall(fireproximityprompt, pp) end
					end
					task.wait(0.4)
				end
			end)
		end
	end
end)

-- avisos: fruta, boss, Mirage, lua cheia
conn(workspace.ChildAdded:Connect(function(c)
	if C.FruitNotify and c.Name:lower():find("fruit") then toast("🍎 Fruta no mapa!", c.Name, 4) end
end))
local BossSet = {}
for _, n in ipairs({"Darkbeard", "Don Swan", "Cake Prince", "Dough King", "rip_indra", "Order", "Soul Reaper", "Cursed Captain",
	"Tyrant of the Skies", "Longma", "Awakened Ice Admiral", "Stone", "Island Empress", "Kilo Admiral", "Captain Elephant",
	"Beautiful Pirate", "Cake Queen", "Diablo", "Urban", "Deandre", "Thunder God", "Magma Admiral", "Fajita", "Smoke Admiral"}) do BossSet[n] = true end
task.spawn(function()
	local en = workspace:WaitForChild("Enemies", 20)
	if en then
		conn(en.ChildAdded:Connect(function(c)
			if C.BossNotify and BossSet[c.Name] then toast("👑 Boss spawnou!", c.Name, 5) end
		end))
	end
end)
local seenMirage, seenMoon = false, false
local FULL_MOON = "http://www.roblox.com/asset/?id=9709149431"
loop(6, function()
	local map = workspace:FindFirstChild("Map")
	local m = map and map:FindFirstChild("MirageIsland")
	if m and not seenMirage and C.MirageNotify then toast("🏝 Ilha Mirage!", "Apareceu no mapa", 6) end
	seenMirage = m ~= nil
	local sky = Lighting:FindFirstChildOfClass("Sky")
	local full = (sky and sky.MoonTextureId == FULL_MOON) and true or false
	if full and not seenMoon and C.MoonNotify then toast("🌕 Lua cheia!", "Detectada no céu", 6) end
	seenMoon = full
end)

local function islandItems()
	local out = {}
	local ok, f = pcall(function() return workspace._WorldOrigin.Locations end)
	if ok and f then
		for _, p in ipairs(f:GetChildren()) do
			if p:IsA("BasePart") then out[#out + 1] = {label = p.Name, pos = p.Position + Vector3.new(0, 45, 0)} end
		end
	end
	table.sort(out, function(a, b) return a.label < b.label end)
	if #out == 0 then out[1] = {label = "Nenhuma ilha encontrada (toque em Atualizar)"} end
	return out
end
local function playerItems()
	local out = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp then out[#out + 1] = {label = p.DisplayName .. "  (@" .. p.Name .. ")", plr = p} end
	end
	if #out == 0 then out[1] = {label = "Nenhum outro jogador"} end
	return out
end
local function stockItems()
	local out = {}
	local res = invoke("GetFruits")
	if type(res) == "table" then
		for _, f in ipairs(res) do
			if type(f) == "table" and f.OnSale then out[#out + 1] = {label = tostring(f.Name) .. "  •  $" .. commas(f.Price), name = f.Name} end
		end
	end
	if #out == 0 then out[1] = {label = "Estoque não lido (toque em Atualizar)"} end
	return out
end
local function spectate(plr)
	local c = plr and plr.Character
	local h = c and c:FindFirstChildOfClass("Humanoid")
	if h then workspace.CurrentCamera.CameraSubject = h end
end
local function stopSpectate()
	local c = lp.Character
	local h = c and c:FindFirstChildOfClass("Humanoid")
	if h then workspace.CurrentCamera.CameraSubject = h end
end

------------------------------------------------------------------
-- PERFIS VISUAIS
------------------------------------------------------------------
local Profiles = {
	Natal = {Snow = true, SnowShape = "Floco", SnowColor = "Branco", SnowCount = 70, SnowSpeed = 40, SnowSize = 16, SnowWind = 10, SnowDir = "Cair",
		Neon = true, NeonMode = "Dourado", Gradient = true, GradPreset = "Aurora", LineMode = "Dourado", BtnColor = "Dourado", BtnIcon = "❄", BtnStyle = "Neon"},
	Sakura = {Snow = true, SnowShape = "Flor", SnowColor = "Rosa", SnowCount = 35, SnowSpeed = 35, SnowSize = 16, SnowWind = 25, SnowDir = "Cair",
		Neon = true, NeonMode = "Rosa", Gradient = true, GradPreset = "Pôr do sol", LineMode = "Rosa", BtnColor = "Rosa", BtnIcon = "✿", BtnStyle = "Neon"},
	Matrix = {Snow = true, SnowShape = "Bolinha", SnowColor = "Verde", SnowCount = 90, SnowSpeed = 130, SnowSize = 10, SnowWind = 0, SnowDir = "Cair",
		Neon = true, NeonMode = "Verde", Gradient = true, GradPreset = "Neon", LineMode = "Verde", BtnColor = "Verde", BtnIcon = "◆", BtnShape = "Diamante", BtnStyle = "Vidro"},
	["Galáxia"] = {Snow = true, SnowShape = "Estrela", SnowColor = "Lilás", SnowCount = 60, SnowSpeed = 20, SnowSize = 14, SnowWind = 5, SnowDir = "Subir",
		Neon = true, NeonMode = "Lilás", Gradient = true, GradPreset = "Aurora", LineMode = "Lilás", BtnColor = "Lilás", BtnIcon = "✦", BtnShape = "Squircle", BtnStyle = "Neon"},
	["Maçã"] = {Snow = true, SnowShape = "Maçã", SnowColor = "Branco", SnowCount = 25, SnowSpeed = 40, SnowSize = 18, SnowWind = 12, SnowDir = "Cair",
		Neon = true, NeonMode = "Tema", Gradient = true, GradPreset = "Tema", LineMode = "Padrão", BtnColor = "Tema", BtnIcon = "🍎", BtnShape = "Círculo", BtnStyle = "Vidro"},
	["Arco-íris"] = {Snow = true, SnowShape = "Estrela", SnowColor = "Arco-íris", SnowCount = 55, SnowSpeed = 50, SnowSize = 14, SnowWind = 15, SnowDir = "Cair",
		Neon = true, NeonMode = "Arco-íris", NeonSpeed = 120, Gradient = true, GradPreset = "Arco-íris", LineMode = "Arco-íris", BtnColor = "Arco-íris", BtnIcon = "★", BtnStyle = "Neon", TitleMode = "Arco-íris"},
	Minimalista = {Snow = false, Neon = false, Gradient = false, LineMode = "Padrão", BtnPulse = false, BtnSpin = false, BtnStyle = "Sólido", BtnColor = "Tema", BtnIcon = "A", Ripple = false, TitleMode = "Padrão"},
}
local ProfileNames = {"Natal", "Sakura", "Matrix", "Galáxia", "Maçã", "Arco-íris", "Minimalista"}
local syncs = {}
local function applyProfile(n)
	local p = Profiles[n]
	if not p then return end
	for k, v in pairs(p) do C[k] = v end
	applyPanel() applyBtn() applyTabs()
	for _, s in ipairs(syncs) do pcall(s) end
	toast("Perfil", n .. " aplicado", 2)
end

------------------------------------------------------------------
-- STUDIO
------------------------------------------------------------------
local studio = new("CanvasGroup", {Name = "Studio", Size = UDim2.new(1, -16, 1, -50), Position = UDim2.fromOffset(8, 42), BackgroundTransparency = 0.02,
	GroupTransparency = 1, Visible = false, ZIndex = 20, Parent = main})
rc(studio, 16)
bind(studio, "BackgroundColor3", function() return P.bg end)

local function label(props, bold, key, class)
	props.BackgroundTransparency = 1
	props.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	local o = new(class or "TextLabel", props)
	if key ~= false then local k = key or "text" bind(o, "TextColor3", function() return P[k] end) end
	return o
end
local function mkRow(pg, h)
	local r = new("Frame", {Size = UDim2.new(1, -4, 0, h or 40), BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = pg})
	rc(r, 12)
	bind(r, "BackgroundColor3", function() return P.row end)
	return r
end
local function Section(pg, t)
	label({Size = UDim2.new(1, -4, 0, 22), Text = string.upper(t), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = pg}, true, "acc")
end
local function Info(pg, t)
	label({Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = t, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = pg}, false, "sub")
end
local function applyAll() if applyPanel then applyPanel() end if applyBtn then applyBtn() end applyTabs() end
local function syncAll() for _, s in ipairs(syncs) do pcall(s) end end
local function Toggle(pg, text, key, cb)
	local r = mkRow(pg, 40)
	label({Size = UDim2.new(1, -70, 1, 0), Position = UDim2.fromOffset(14, 0), Text = text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = r})
	local sw = new("TextButton", {Size = UDim2.fromOffset(44, 24), Position = UDim2.new(1, -58, 0.5, -12), Text = "", AutoButtonColor = false, Parent = r})
	rc(sw, 12)
	local knob = new("Frame", {Size = UDim2.fromOffset(20, 20), Position = C[key] and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = sw})
	rc(knob, 10)
	local rf = bind(sw, "BackgroundColor3", function() return C[key] and P.acc or P.row:Lerp(P.sub, 0.4) end)
	syncs[#syncs + 1] = function() knob.Position = C[key] and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2) rf() end
	sw.MouseButton1Click:Connect(function()
		C[key] = not C[key]
		rf()
		tween(knob, 0.25, {Position = C[key] and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)}, Enum.EasingStyle.Back)
		applyAll()
		if cb then task.spawn(function() local ok, e = pcall(cb, C[key]) if not ok then toast("Erro", tostring(e)) end end) end
	end)
end
local function Slider(pg, text, min, max, key, cb, suffix)
	suffix = suffix or ""
	local r = mkRow(pg, 56)
	label({Size = UDim2.new(0.6, 0, 0, 26), Position = UDim2.fromOffset(14, 2), Text = text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = r})
	local vl = label({Size = UDim2.new(0.4, -28, 0, 26), Position = UDim2.new(0.6, 14, 0, 2), Text = C[key] .. suffix, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right, Parent = r}, true, "acc")
	local bar = new("Frame", {Size = UDim2.new(1, -28, 0, 8), Position = UDim2.fromOffset(14, 38), BorderSizePixel = 0, Parent = r})
	rc(bar, 4)
	bind(bar, "BackgroundColor3", function() return P.row:Lerp(P.sub, 0.35) end)
	local a0 = math.clamp((C[key] - min) / (max - min), 0, 1)
	local fill = new("Frame", {Size = UDim2.new(a0, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = bar})
	rc(fill, 4)
	local fg = new("UIGradient", {Parent = fill})
	bind(fg, "Color", function() return ColorSequence.new(P.acc, P.acc2) end)
	local knob = new("Frame", {Size = UDim2.fromOffset(16, 16), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = fill})
	rc(knob, 8)
	syncs[#syncs + 1] = function()
		fill.Size = UDim2.new(math.clamp((C[key] - min) / (max - min), 0, 1), 0, 1, 0)
		vl.Text = C[key] .. suffix
	end
	local sliding = false
	local function set(x)
		local a = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		local v = math.floor(min + (max - min) * a + 0.5)
		C[key] = v
		fill.Size = UDim2.new(a, 0, 1, 0)
		vl.Text = v .. suffix
		applyAll()
		if cb then pcall(cb, v) end
	end
	local hit = new("TextButton", {Size = UDim2.new(1, 0, 0, 28), Position = UDim2.fromOffset(0, 28), BackgroundTransparency = 1, Text = "", Parent = r})
	hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			pg.ScrollingEnabled = false
			set(i.Position.X)
		end
	end)
	conn(UIS.InputChanged:Connect(function(i)
		if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then set(i.Position.X) end
	end))
	conn(UIS.InputEnded:Connect(function(i)
		if sliding and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			sliding = false
			pg.ScrollingEnabled = true
		end
	end))
end
local function Choice(pg, text, options, key, cb)
	local r = new("Frame", {Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = pg})
	rc(r, 12)
	bind(r, "BackgroundColor3", function() return P.row end)
	new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = r})
	new("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = r})
	label({Size = UDim2.new(1, 0, 0, 18), Text = text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0, Parent = r})
	local box = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Parent = r},
		{new("UIGridLayout", {CellSize = UDim2.fromOffset(88, 26), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder})})
	local fs = {}
	for i, o in ipairs(options) do
		local b = new("TextButton", {Text = o, TextSize = 11, Font = Enum.Font.GothamBold, AutoButtonColor = false, TextTruncate = Enum.TextTruncate.AtEnd,
			LayoutOrder = i, Parent = box})
		rc(b, 8)
		fs[#fs + 1] = bind(b, "BackgroundColor3", function() return C[key] == o and P.acc or P.side end)
		fs[#fs + 1] = bind(b, "TextColor3", function() return C[key] == o and Color3.new(1, 1, 1) or P.text end)
		b.MouseButton1Click:Connect(function()
			C[key] = o
			for _, f in ipairs(fs) do f() end
			applyAll()
			if cb then task.spawn(function() local ok, e = pcall(cb, o) if not ok then toast("Erro", tostring(e)) end end) end
		end)
	end
	syncs[#syncs + 1] = function() for _, f in ipairs(fs) do f() end end
end
local function Button(pg, text, cb)
	local b = new("TextButton", {Size = UDim2.new(1, -4, 0, 38), BackgroundColor3 = Color3.new(1, 1, 1), Text = text, TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false, Parent = pg})
	rc(b, 12)
	local g = new("UIGradient", {Parent = b})
	bind(g, "Color", function() return ColorSequence.new(P.acc, P.acc2) end)
	b.MouseButton1Click:Connect(function()
		b.BackgroundTransparency = 0.35
		tween(b, 0.3, {BackgroundTransparency = 0})
		task.spawn(function() local ok, e = pcall(cb) if not ok then toast("Erro", tostring(e)) end end)
	end)
end
local function Input(pg, text, ph, key, cb)
	local r = mkRow(pg, 40)
	label({Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.fromOffset(14, 0), Text = text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = r})
	local box = label({Size = UDim2.new(0.6, -24, 0, 26), Position = UDim2.new(0.4, 6, 0.5, -13), Text = tostring(C[key]), PlaceholderText = ph, TextSize = 12,
		ClearTextOnFocus = false, Parent = r}, false, "text", "TextBox")
	box.BackgroundTransparency = 0.3
	rc(box, 8)
	bind(box, "BackgroundColor3", function() return P.side end)
	syncs[#syncs + 1] = function() box.Text = tostring(C[key]) end
	box.FocusLost:Connect(function()
		C[key] = box.Text:sub(1, 80)
		applyAll()
		if cb then pcall(cb, box.Text) end
	end)
end
local function DynList(pg, title, getItems, onPick, lazy)
	local r = new("Frame", {Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = pg})
	rc(r, 12)
	bind(r, "BackgroundColor3", function() return P.row end)
	new("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = r})
	new("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = r})
	local head = new("Frame", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 0, Parent = r})
	label({Size = UDim2.new(1, -90, 1, 0), Text = title, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = head}, true)
	local rf = new("TextButton", {Size = UDim2.fromOffset(80, 24), Position = UDim2.new(1, -80, 0, 0), Text = "↻ Atualizar", Font = Enum.Font.GothamBold,
		TextSize = 11, AutoButtonColor = false, Parent = head})
	rc(rf, 8)
	bind(rf, "BackgroundColor3", function() return P.acc end)
	rf.TextColor3 = Color3.new(1, 1, 1)
	local box = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Parent = r},
		{new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})})
	local function rebuild()
		local ok, items = pcall(getItems)
		if not ok then items = {} end
		for _, c in ipairs(box:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		for i, it in ipairs(items) do
			local b = new("TextButton", {Size = UDim2.new(1, 0, 0, 28), Text = it.label, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
				TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = i, Parent = box})
			rc(b, 8)
			bind(b, "BackgroundColor3", function() return P.side end)
			bind(b, "TextColor3", function() return P.text end)
			b.MouseButton1Click:Connect(function() task.spawn(function() local ok2, e = pcall(onPick, it) if not ok2 then toast("Erro", tostring(e)) end end) end)
		end
	end
	rf.MouseButton1Click:Connect(function() task.spawn(rebuild) end)
	if not lazy then task.spawn(rebuild) end
	return rebuild
end
local function CodeBox(pg, ph)
	local r = mkRow(pg, 84)
	local box = label({Size = UDim2.new(1, -24, 1, -16), Position = UDim2.fromOffset(12, 8), Text = "", PlaceholderText = ph, TextSize = 11, TextWrapped = true,
		MultiLine = true, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = r}, false, "text", "TextBox")
	box.BackgroundTransparency = 0.3
	rc(box, 8)
	bind(box, "BackgroundColor3", function() return P.side end)
	return box
end

-- abas do Studio
local tabBar = new("ScrollingFrame", {Size = UDim2.new(1, -52, 0, 30), Position = UDim2.fromOffset(8, 6), BackgroundTransparency = 1, BorderSizePixel = 0,
	ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X, Parent = studio},
	{new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})})
local studioPages, tabFs, curTab = {}, {}, nil
local function selectTab(n)
	curTab = n
	for k, p in pairs(studioPages) do p.Visible = (k == n) end
	for _, f in ipairs(tabFs) do f() end
end
local tabIdx = 0
local function addTab(name)
	tabIdx = tabIdx + 1
	local sc = new("ScrollingFrame", {Size = UDim2.new(1, -16, 1, -46), Position = UDim2.fromOffset(8, 40), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false, Parent = studio},
		{new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}),
		 new("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 12)})})
	bind(sc, "ScrollBarImageColor3", function() return P.acc end)
	studioPages[name] = sc
	local b = new("TextButton", {Size = UDim2.new(0, 0, 1, -2), AutomaticSize = Enum.AutomaticSize.X, Text = name, Font = Enum.Font.GothamBold, TextSize = 12,
		AutoButtonColor = false, LayoutOrder = tabIdx, Parent = tabBar}, {new("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})})
	rc(b, 10)
	tabFs[#tabFs + 1] = bind(b, "BackgroundColor3", function() return curTab == name and P.acc or P.row end)
	tabFs[#tabFs + 1] = bind(b, "TextColor3", function() return curTab == name and Color3.new(1, 1, 1) or P.text end)
	b.MouseButton1Click:Connect(function() selectTab(name) end)
	return sc
end
local closeBtn = new("TextButton", {Size = UDim2.fromOffset(30, 28), Position = UDim2.new(1, -38, 0, 6), Text = "✕", Font = Enum.Font.GothamBold, TextSize = 14,
	AutoButtonColor = false, Parent = studio})
rc(closeBtn, 10)
bind(closeBtn, "BackgroundColor3", function() return P.row end)
bind(closeBtn, "TextColor3", function() return P.text end)

local pill = new("TextButton", {Size = UDim2.fromOffset(70, 22), Position = UDim2.new(1, -222, 0, 9), BackgroundColor3 = Color3.new(1, 1, 1), Text = "✦ Studio",
	TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, Parent = top})
rc(pill, 11)
local pillG = new("UIGradient", {Parent = pill})
bind(pillG, "Color", function() return ColorSequence.new(P.acc, P.acc2) end)
local studioOpen = false
local function setStudio(v)
	studioOpen = v
	pill.Text = v and "✕ Fechar" or "✦ Studio"
	if v then
		studio.Visible = true
		tween(studio, 0.3, {GroupTransparency = 0})
	else
		tween(studio, 0.2, {GroupTransparency = 1})
		task.delay(0.22, function() if not studioOpen then studio.Visible = false end end)
	end
end
pill.MouseButton1Click:Connect(function() setStudio(not studioOpen) end)
closeBtn.MouseButton1Click:Connect(function() setStudio(false) end)

local function saveCfg()
	local d = {}
	for k, v in pairs(C) do if not NOSAVE[k] then d[k] = v end end
	local ok = pcall(function() writefile(FILE, HttpService:JSONEncode(d)) end)
	toast("Config", ok and "Aparência salva!" or "Executor não permite salvar.", 3)
end

-- PERFIS
local pProf = addTab("Perfis")
Section(pProf, "Estilos prontos (1 toque)")
Choice(pProf, "Escolha um perfil", ProfileNames, "Profile", applyProfile)
Info(pProf, "Um perfil muda neve, borda, degradê, linha e botão de uma vez. Depois ajuste o que quiser nas outras abas.")

-- EDITOR DE TEMAS
local pEd = addTab("Editor")
local THEMES = "AppleHubPlusThemes.json"
local SKIP = {Profile = true, PaletteSel = true, ThemeName = true, BtnX = true, BtnY = true}
local function snapshot()
	local d = {}
	for k, v in pairs(C) do if not NOSAVE[k] and not SKIP[k] then d[k] = v end end
	return d
end
local function applyTheme(d)
	local n = 0
	for k, v in pairs(d) do
		if C[k] ~= nil and type(v) == type(C[k]) and not NOSAVE[k] and not SKIP[k] then
			C[k] = sanitize(k, v)
			n = n + 1
		end
	end
	applyAll()
	syncAll()
	return n
end
local function loadThemes()
	local ok, d = pcall(function() return HttpService:JSONDecode(readfile(THEMES)) end)
	return (ok and type(d) == "table") and d or {}
end
local function saveThemes(t)
	return pcall(function() writefile(THEMES, HttpService:JSONEncode(t)) end)
end

local PALETTES = {
	Oceano = {Color3.fromRGB(0, 200, 255), Color3.fromRGB(0, 90, 255)},
	["Pôr do sol"] = {Color3.fromRGB(255, 150, 60), Color3.fromRGB(255, 40, 110)},
	Sakura = {Color3.fromRGB(255, 170, 205), Color3.fromRGB(200, 110, 255)},
	Matrix = {Color3.fromRGB(60, 255, 100), Color3.fromRGB(0, 140, 70)},
	Gelo = {Color3.fromRGB(190, 240, 255), Color3.fromRGB(90, 150, 255)},
	Ouro = {Color3.fromRGB(255, 225, 110), Color3.fromRGB(255, 150, 20)},
	Vulcão = {Color3.fromRGB(255, 80, 40), Color3.fromRGB(150, 0, 30)},
	["Neon Rosa"] = {Color3.fromRGB(255, 50, 200), Color3.fromRGB(80, 60, 255)},
}
local PaletteNames = {"Oceano", "Pôr do sol", "Sakura", "Matrix", "Gelo", "Ouro", "Vulcão", "Neon Rosa"}

Section(pEd, "Cores Custom (ao vivo)")
local prevRow = mkRow(pEd, 46)
local prevBar = new("Frame", {Size = UDim2.new(1, -28, 0, 26), Position = UDim2.fromOffset(14, 10), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = prevRow})
rc(prevBar, 8)
local prevG = new("UIGradient", {Parent = prevBar})
local function updPrev() prevG.Color = ColorSequence.new(customA(), customB()) end
updPrev()
syncs[#syncs + 1] = updPrev
Slider(pEd, "Cor A  •  matiz", 0, 360, "CAh", updPrev)
Slider(pEd, "Cor A  •  saturação", 0, 100, "CAs", updPrev, "%")
Slider(pEd, "Cor A  •  brilho", 0, 100, "CAv", updPrev, "%")
Slider(pEd, "Cor B  •  matiz", 0, 360, "CBh", updPrev)
Slider(pEd, "Cor B  •  saturação", 0, 100, "CBs", updPrev, "%")
Slider(pEd, "Cor B  •  brilho", 0, 100, "CBv", updPrev, "%")
Choice(pEd, "Paletas rápidas", PaletteNames, "PaletteSel", function(name)
	local p = PALETTES[name]
	if not p then return end
	local h1, s1, v1 = p[1]:ToHSV()
	local h2, s2, v2 = p[2]:ToHSV()
	C.CAh, C.CAs, C.CAv = math.floor(h1 * 360), math.floor(s1 * 100), math.floor(v1 * 100)
	C.CBh, C.CBs, C.CBv = math.floor(h2 * 360), math.floor(s2 * 100), math.floor(v2 * 100)
	applyAll()
	syncAll()
end)
Button(pEd, "🎨  Aplicar cores Custom em tudo", function()
	for _, k in ipairs({"NeonMode", "SnowColor", "LineMode", "BtnColor", "IntroColor", "RippleColor", "GradPreset", "TitleMode"}) do C[k] = "Custom" end
	applyAll()
	syncAll()
	toast("Editor", "Tema Custom aplicado!", 2.5)
end)
Info(pEd, "Em cada aba, escolha \"Custom\" na lista de cor para usar só onde quiser.")

Section(pEd, "Meus temas")
Input(pEd, "Nome", "nome do tema", "ThemeName")
local refreshThemes
refreshThemes = DynList(pEd, "Temas salvos (toque p/ aplicar)", function()
	local out, t = {}, loadThemes()
	for name, data in pairs(t) do out[#out + 1] = {label = tostring(name), data = data} end
	table.sort(out, function(a, b) return a.label < b.label end)
	if #out == 0 then out[1] = {label = "Nenhum tema salvo ainda"} end
	return out
end, function(it)
	if type(it.data) ~= "table" then return end
	local n = applyTheme(it.data)
	toast("Tema", it.label .. " aplicado (" .. n .. " opções)", 2.5)
end)
Button(pEd, "💾  Salvar tema atual com esse nome", function()
	local name = (C.ThemeName or ""):match("^%s*(.-)%s*$")
	if name == "" then toast("Tema", "Digite um nome primeiro", 2.5) return end
	local t = loadThemes()
	t[name] = snapshot()
	local ok = saveThemes(t)
	toast("Tema", ok and ("Salvo: " .. name) or "Executor não permite salvar", 3)
	task.spawn(refreshThemes)
end)
Button(pEd, "🗑  Apagar tema pelo nome", function()
	local name = (C.ThemeName or ""):match("^%s*(.-)%s*$")
	local t = loadThemes()
	if t[name] == nil then toast("Tema", "Não achei esse nome", 2.5) return end
	t[name] = nil
	saveThemes(t)
	toast("Tema", "Apagado: " .. name, 2.5)
	task.spawn(refreshThemes)
end)

Section(pEd, "Compartilhar")
local outBox = CodeBox(pEd, "O código do seu tema aparece aqui")
Button(pEd, "📤  Gerar código do tema", function()
	local code = "AHP1:" .. HttpService:JSONEncode(snapshot())
	outBox.Text = code
	local ok = pcall(function() setclipboard(code) end)
	toast("Tema", ok and "Código copiado!" or "Segure o texto para copiar", 3)
end)
local inBox = CodeBox(pEd, "Cole aqui o código de um tema (AHP1:...)")
Button(pEd, "📥  Importar código", function()
	local s = (inBox.Text or ""):match("^%s*(.-)%s*$")
	s = s:gsub("^AHP1:", "")
	local ok, d = pcall(function() return HttpService:JSONDecode(s) end)
	if not ok or type(d) ~= "table" then toast("Tema", "Código inválido", 3) return end
	local n = applyTheme(d)
	toast("Tema", n > 0 and ("Importado: " .. n .. " opções") or "Nada para importar", 3)
end)
Info(pEd, "Importar só altera aparência e limita valores extremos, então códigos de outras pessoas não travam o hub.")

-- PAINEL
local pPanel = addTab("Painel")
Section(pPanel, "Borda neon")
Toggle(pPanel, "Borda neon animada", "Neon")
Slider(pPanel, "Espessura", 1, 6, "NeonThick")
Slider(pPanel, "Velocidade da rotação", 0, 200, "NeonSpeed")
Choice(pPanel, "Cor da borda", ColorModes, "NeonMode")
Section(pPanel, "Fundo degradê")
Toggle(pPanel, "Degradê no fundo", "Gradient")
Choice(pPanel, "Estilo do degradê", {"Tema", "Custom", "Pôr do sol", "Oceano", "Neon", "Aurora", "Arco-íris"}, "GradPreset")
Slider(pPanel, "Transparência", 40, 100, "GradAlpha", nil, "%")
Slider(pPanel, "Velocidade do giro", 0, 120, "GradSpeed")
Section(pPanel, "Linha do topo")
Slider(pPanel, "Espessura da linha", 1, 8, "LineThick")
Choice(pPanel, "Cor da linha", {"Padrão", "Custom", "Arco-íris", "Branco", "Rosa", "Dourado", "Ciano", "Lilás", "Verde"}, "LineMode")
Section(pPanel, "Título")
Slider(pPanel, "Tamanho do título", 10, 24, "TitleSize")
Choice(pPanel, "Cor do título", {"Padrão", "Tema", "Custom", "Arco-íris", "Branco", "Rosa", "Dourado", "Ciano"}, "TitleMode")
Section(pPanel, "Efeitos")
Toggle(pPanel, "Ondas ao tocar", "Ripple")
Choice(pPanel, "Cor das ondas", ColorModes, "RippleColor")
Section(pPanel, "Transparências")
Slider(pPanel, "Barra lateral", 0, 90, "SideAlpha", nil, "%")
Slider(pPanel, "Itens e cartões", 0, 90, "RowAlpha", nil, "%")

-- PARTÍCULAS
local pSnow = addTab("Partículas")
Section(pSnow, "Neve / partículas")
Toggle(pSnow, "Partículas caindo", "Snow")
Toggle(pSnow, "Na frente dos botões", "SnowFront")
Toggle(pSnow, "Tela inteira (fora do painel)", "SnowFull")
Toggle(pSnow, "Piscar (brilho variando)", "SnowTwinkle")
Slider(pSnow, "Quantidade", 5, 120, "SnowCount")
Slider(pSnow, "Velocidade", 5, 200, "SnowSpeed")
Slider(pSnow, "Tamanho", 6, 40, "SnowSize")
Slider(pSnow, "Vento", -60, 60, "SnowWind")
Slider(pSnow, "Transparência", 0, 90, "SnowAlpha", nil, "%")
Choice(pSnow, "Formato", ShapeNames, "SnowShape")
Choice(pSnow, "Cor", ColorModes, "SnowColor")
Choice(pSnow, "Direção", {"Cair", "Subir"}, "SnowDir")
Toggle(pSnow, "Girar partículas", "SnowSpin")
Toggle(pSnow, "Tamanhos variados", "SnowSizeVar")

-- BOTÃO
local pBtn = addTab("Botão")
Section(pBtn, "Botão flutuante")
Toggle(pBtn, "Mostrar botão", "Btn")
Toggle(pBtn, "Esconder bolha antiga do hub", "HideBubble")
Slider(pBtn, "Tamanho", 36, 90, "BtnSize", nil, " px")
Choice(pBtn, "Formato", {"Círculo", "Squircle", "Quadrado", "Diamante"}, "BtnShape")
Choice(pBtn, "Estilo", {"Neon", "Vidro", "Sólido"}, "BtnStyle")
Choice(pBtn, "Cor", ColorModes, "BtnColor")
Toggle(pBtn, "Pulso animado", "BtnPulse")
Toggle(pBtn, "Anel girando", "BtnSpin")
Input(pBtn, "Ícone", "símbolo ou emoji", "BtnIcon")
Button(pBtn, "Resetar posição do botão", function()
	C.BtnX, C.BtnY = 0.06, 0.4
	btn.Position = UDim2.fromScale(C.BtnX, C.BtnY)
end)
Info(pBtn, "Toque no botão para esconder/mostrar o hub. Segure e arraste para mover.")

-- ABAS
local pTabs = addTab("Abas")
Section(pTabs, "Abas do hub")
Slider(pTabs, "Tamanho do texto", 10, 18, "TabSize")
Choice(pTabs, "Fonte das abas", {"GothamBold", "Gotham", "SourceSans", "Arial", "Roboto", "Ubuntu", "Nunito", "Oswald", "Jura", "Michroma", "FredokaOne", "Code", "SciFi"}, "TabFont")
Toggle(pTabs, "Nomes em MAIÚSCULAS", "TabCaps")
Toggle(pTabs, "Animação ao tocar / passar", "TabHover")
Section(pTabs, "Indicador da aba")
Slider(pTabs, "Arredondamento", 0, 20, "TabIndR")
Slider(pTabs, "Transparência", 0, 80, "TabIndAlpha", nil, "%")
Toggle(pTabs, "Brilho em volta", "TabIndGlow")

-- INTRO
local pIntro = addTab("Intro")
Section(pIntro, "Intro")
Toggle(pIntro, "Tocar ao iniciar", "Intro")
Input(pIntro, "Título", "nome na intro", "IntroText")
Input(pIntro, "Subtítulo", "frase abaixo", "IntroSub")
Choice(pIntro, "Estilo", {"Letras", "Zoom", "Glitch", "Digitar", "Portal"}, "IntroStyle")
Choice(pIntro, "Cor", ColorModes, "IntroColor")
Choice(pIntro, "Fundo", {"Preto", "Tema", "Gradiente"}, "IntroBg")
Slider(pIntro, "Duração (x 0,1 s)", 20, 80, "IntroTime")
Toggle(pIntro, "Barra de carregamento", "IntroBar")
Toggle(pIntro, "Tocar na tela pula a intro", "IntroSkip")
Button(pIntro, "▶  Pré-visualizar intro", function() setStudio(false) task.spawn(playIntro) end)

-- BLOX
local pBlox = addTab("Blox")
Section(pBlox, "Avisos")
Toggle(pBlox, "Fruta nova no mapa", "FruitNotify")
Toggle(pBlox, "Boss spawnou", "BossNotify")
Toggle(pBlox, "Ilha Mirage apareceu", "MirageNotify")
Toggle(pBlox, "Lua cheia (experimental)", "MoonNotify")
Section(pBlox, "Frutas")
Toggle(pBlox, "Auto comprar fruta aleatória", "AutoFruitBuy")
Slider(pBlox, "Intervalo da compra", 10, 120, "FruitBuyDelay", nil, " s")
DynList(pBlox, "Estoque do vendedor (toque p/ comprar)", stockItems, function(it)
	if not it.name then return end
	local r = invoke("PurchaseRawFruit", it.name)
	toast("Compra", r and tostring(r) or "Sem resposta do servidor", 3)
end, true)
Section(pBlox, "Coleta e raça")
Toggle(pBlox, "Auto Berries (experimental)", "AutoBerry")
Toggle(pBlox, "Auto habilidade da raça (V3)", "AutoRace")
Section(pBlox, "Viagem")
Slider(pBlox, "Velocidade de viagem", 100, 600, "TravelSpeed", nil, " st/s")
Button(pBlox, "Ir até a Ilha Mirage", function()
	local map = workspace:FindFirstChild("Map")
	local m = map and map:FindFirstChild("MirageIsland")
	if not m then toast("Mirage", "Não está no mapa agora", 2.5) return end
	goTo(m:GetPivot().Position + Vector3.new(0, 250, 0))
end)
DynList(pBlox, "Ilhas do mar atual", islandItems, function(it)
	if not it.pos then return end
	toast("Viajando", it.label, 2)
	goTo(it.pos)
end)
DynList(pBlox, "Ir até um jogador", playerItems, function(it)
	local c = it.plr and it.plr.Character
	local hr = c and c:FindFirstChild("HumanoidRootPart")
	if hr then toast("Viajando", it.plr.DisplayName, 2) goTo(hr.Position + Vector3.new(0, 4, 0)) end
end)
DynList(pBlox, "Observar jogador", playerItems, function(it)
	if it.plr then spectate(it.plr) toast("Observando", it.plr.DisplayName, 2) end
end)
Button(pBlox, "Parar de observar", stopSpectate)

-- SALVAR
local pSave = addTab("Salvar")
Section(pSave, "Configuração")
Button(pSave, "Salvar aparência", saveCfg)
Button(pSave, "Apagar config salva", function()
	local ok = pcall(function() if isfile(FILE) then delfile(FILE) end end)
	toast("Config", ok and "Apagada. Reexecute o script." or "Não foi possível apagar.", 3)
end)
Info(pSave, "As opções do Studio valem na hora. Salve para manter ao reexecutar. Os autos da aba Blox nunca são salvos ligados.")

------------------------------------------------------------------
-- ANIMAÇÕES + TEMA
------------------------------------------------------------------
conn(RS.RenderStepped:Connect(function(dt)
	if not alive then return end
	hueT = (hueT + dt * 0.12) % 1
	pcall(updateSnow, dt)
	pcall(function()
		neonG.Rotation = (neonG.Rotation + C.NeonSpeed * dt) % 360
		overG.Rotation = (overG.Rotation + C.GradSpeed * dt) % 360
		if myLine.Visible then lineG.Offset = Vector2.new(((os.clock() * 0.5) % 2) - 1, 0) end
		if titleLabel and C.TitleMode ~= "Padrão" then titleLabel.TextColor3 = modeColor(C.TitleMode, 0) end
		if main.GroupTransparency < 0.05 and uiscale then baseScale = uiscale.Scale end
		if C.Btn then
			if C.BtnSpin then ringG.Rotation = (ringG.Rotation + 140 * dt) % 360 btnG.Rotation = (btnG.Rotation + 40 * dt) % 360 end
			if C.BtnPulse then
				local ph = (os.clock() * 0.9) % 1
				pulse.Size = UDim2.fromScale(1 + ph * 0.55, 1 + ph * 0.55)
				pulseStroke.Transparency = 0.25 + 0.75 * ph
				pulseG.Rotation = (pulseG.Rotation + 90 * dt) % 360
			end
			if C.BtnColor == "Arco-íris" then
				if C.BtnStyle == "Vidro" then icon.TextColor3 = modeColor("Arco-íris", 0)
				elseif C.BtnStyle == "Sólido" then btn.BackgroundColor3 = modeColor("Arco-íris", 0) end
			end
		end
		if dirty.rows then dirty.rows = false applyRows() end
	end)
end))
loop(0.4, function() refreshPalette() end)

------------------------------------------------------------------
-- UNLOAD
------------------------------------------------------------------
local function unload()
	if not alive then return end
	alive = false
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	pcall(stopSpectate)
	pcall(function()
		for _, t in ipairs(tabBtns) do t.b.Text = t.text t.b.TextSize = t.size t.b.Font = t.font end
		if indicator then indicator.BackgroundTransparency = 0 end
		if indStroke then indStroke:Destroy() end
		topLine.Size = UDim2.new(1, 0, 0, 3)
		side.BackgroundTransparency = 0.2
		if titleLabel then titleLabel.TextSize = 13 end
		for _, o in ipairs({snowLayer, rippleLayer, neon, over, myLine, studio, pill}) do o:Destroy() end
		gui:Destroy()
	end)
end
if getgenv then
	local prev = getgenv().AppleHubUnload
	getgenv().ApplePlusUnload = unload
	getgenv().AppleHubUnload = function() pcall(unload) if prev then pcall(prev) end end
end
conn(hub.AncestryChanged:Connect(function(_, p) if not p then unload() end end))

------------------------------------------------------------------
-- INÍCIO
------------------------------------------------------------------
refreshPalette(true)
applyTabs()
selectTab("Perfis")
if C.Intro then task.spawn(playIntro) end
task.delay(1, function() toast("Apple Hub Plus v9", "Toque em ✦ Studio → Editor para criar seu tema!", 4) end)
