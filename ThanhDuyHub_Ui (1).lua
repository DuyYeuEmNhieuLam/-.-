--[[
	LiquidGlass UI Library  (Roblox / Luau)
	Phong cách kính mờ: sidebar + tìm kiếm, tab dạng pill, toggle, slider,
	dropdown trượt từ cạnh phải, đổi theme trực tiếp, nút nổi, thông báo.

	Dùng như ModuleScript:   local Library = require(path.to.LiquidGlass)

	Một file duy nhất (loadstring hoặc require đều được): lõi + Section, Label, Button, Toggle, Slider,
	Dropdown, Input, Paragraph, Cards (Discord/YouTube/TikTok), Music engine + AddMusicPlayer.
	Tab dựng sẵn (gọi khi cần): Window:AddSettingsTab / AddMusicTab / AddInfoTab

	Text chạy theo code: Title / Description / Content / Name / Stat có thể là
	string HOẶC function trả về string (tự cập nhật), hoặc bảng gồm nhiều dòng.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")

local Library = {}
Library.__index = Library
Library.Version = "1.2.0"
Library.AnimationSpeed = 1 -- nhân tốc độ mọi animation (0.5 = chậm, 2 = nhanh)

local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab

local FONT = Enum.Font.Gotham
local FONT_MED = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold
local LEFT, RIGHT, CENTER = Enum.TextXAlignment.Left, Enum.TextXAlignment.Right, Enum.TextXAlignment.Center

------------------------------------------------------------------------
-- Themes
-- Key kết thúc bằng "T" là độ trong suốt (Transparency)
------------------------------------------------------------------------
local C = Color3.fromRGB

local function derive(base, over)
	local t = table.clone(base)
	for k, v in pairs(over) do
		t[k] = v
	end
	return t
end

local DARK = {
	Window = C(18, 20, 28), WindowT = 0.25,
	Surface = C(255, 255, 255), SurfaceT = 0.9,
	Stroke = C(255, 255, 255), StrokeT = 0.85,
	Text = C(240, 242, 248), SubText = C(160, 166, 180),
	Accent = C(90, 160, 255),
	Panel = C(14, 16, 22), PanelT = 0.1,
	Sheen = 0.15,
	RimT = 0.85,
}

local LIGHT_GLASS = {
	Window = C(225, 236, 250), WindowT = 0.45,
	Surface = C(255, 255, 255), SurfaceT = 0.6,
	Stroke = C(255, 255, 255), StrokeT = 0.3,
	Text = C(28, 38, 60), SubText = C(88, 100, 125),
	Accent = C(60, 130, 255),
	Panel = C(235, 242, 252), PanelT = 0.35,
	Sheen = 0.3,
	Blur = 14,
	RimT = 0.55,
}

-- Kính kiểu iOS 26: rất trong, blur mạnh, viền sáng kép, bo góc lớn
-- R = hệ số bo góc, RimT = độ trong của viền sáng bên trong, Frost = độ nhòe chiều sâu (DepthOfField)
local Themes = {
	["iOS 26 Glass Dark"] = {
		Window = C(30, 32, 44), WindowT = 0.55,
		Surface = C(255, 255, 255), SurfaceT = 0.9,
		Stroke = C(255, 255, 255), StrokeT = 0.3,
		Text = C(255, 255, 255), SubText = C(180, 188, 206),
		Accent = C(64, 156, 255),
		Panel = C(26, 28, 40), PanelT = 0.35,
		Sheen = 0.35, RimT = 0.5, R = 1.5, Blur = 28, Frost = 0.45,
	},
	["iOS 26 Glass"] = {
		Window = C(246, 248, 253), WindowT = 0.6,
		Surface = C(255, 255, 255), SurfaceT = 0.62,
		Stroke = C(255, 255, 255), StrokeT = 0.1,
		Text = C(18, 22, 34), SubText = C(78, 86, 108),
		Accent = C(10, 132, 255),
		Panel = C(250, 252, 255), PanelT = 0.4,
		Sheen = 0.4, RimT = 0.35, R = 1.5, Blur = 28, Frost = 0.5,
	},
	["iOS 26 Clear"] = {
		Window = C(20, 22, 30), WindowT = 0.78,
		Surface = C(255, 255, 255), SurfaceT = 0.93,
		Stroke = C(255, 255, 255), StrokeT = 0.2,
		Text = C(255, 255, 255), SubText = C(196, 204, 220),
		Accent = C(94, 168, 255),
		Panel = C(18, 20, 28), PanelT = 0.5,
		Sheen = 0.5, RimT = 0.4, R = 1.6, Blur = 34, Frost = 0.6,
	},
	["ThanhDuy Violet"] = derive(DARK, {
		Window = C(30, 14, 52), WindowT = 0.35,
		Accent = C(176, 122, 255), Sheen = 0.3,
		Panel = C(22, 10, 40), PanelT = 0.2,
	}),
	["Liquid Glass"] = LIGHT_GLASS,
	["Liquid Glass Extra"] = derive(LIGHT_GLASS, { WindowT = 0.6, SurfaceT = 0.7, StrokeT = 0.25, PanelT = 0.5, Blur = 22 }),
	["Liquid Glass Ultra"] = derive(LIGHT_GLASS, {
		WindowT = 0.75, SurfaceT = 0.8, StrokeT = 0.2, PanelT = 0.65,
		Text = C(20, 28, 48), SubText = C(70, 82, 108), Blur = 30,
	}),
	["Liquid Glass Dark"] = derive(DARK, {
		Window = C(20, 26, 36), WindowT = 0.45, SurfaceT = 0.88, PanelT = 0.3,
		Accent = C(110, 180, 255), Sheen = 0.25, Blur = 18,
	}),
	["Midnight Blue"] = derive(DARK, { Window = C(10, 18, 40), WindowT = 0.2, Accent = C(80, 140, 255), Panel = C(8, 14, 32) }),
	["Obsidian White"] = derive(DARK, { Window = C(24, 24, 28), WindowT = 0.2, Accent = C(245, 245, 250) }),
	["Crimson Dark"] = derive(DARK, {
		Window = C(26, 12, 16), WindowT = 0.2, Accent = C(230, 60, 80),
		Stroke = C(230, 60, 80), StrokeT = 0.75, Panel = C(20, 8, 12),
	}),
	["Dark"] = derive(DARK, { Window = C(24, 24, 28), WindowT = 0.05, Sheen = 0.05 }),
	["Darker"] = derive(DARK, { Window = C(10, 10, 12), WindowT = 0.02, Panel = C(6, 6, 8), Sheen = 0 }),
	["Light"] = {
		Window = C(244, 245, 248), WindowT = 0.03,
		Surface = C(0, 0, 0), SurfaceT = 0.94,
		Stroke = C(0, 0, 0), StrokeT = 0.88,
		Text = C(25, 27, 33), SubText = C(100, 105, 118),
		Accent = C(40, 110, 240),
		Panel = C(255, 255, 255), PanelT = 0.02,
		Sheen = 0,
		RimT = 0.9,
	},
	["Aqua"] = derive(DARK, { Window = C(10, 36, 44), WindowT = 0.2, Accent = C(40, 215, 220), Panel = C(6, 26, 32) }),
	["Amethyst"] = derive(DARK, { Window = C(26, 16, 40), WindowT = 0.2, Accent = C(170, 110, 255), Panel = C(20, 12, 32) }),
	["Rose"] = derive(DARK, { Window = C(40, 18, 28), WindowT = 0.2, Accent = C(255, 120, 170), Panel = C(32, 12, 22) }),
	["Neon Red"] = derive(DARK, {
		Window = C(30, 6, 10), WindowT = 0.35, Accent = C(255, 50, 50),
		Surface = C(255, 40, 40), SurfaceT = 0.85,
		Stroke = C(255, 50, 50), StrokeT = 0.35, Panel = C(20, 4, 8), PanelT = 0.15,
	}),
}

local ThemeOrder = {
	"ThanhDuy Violet",
	"iOS 26 Glass Dark", "iOS 26 Glass", "iOS 26 Clear",
	"Liquid Glass", "Liquid Glass Extra", "Liquid Glass Ultra", "Liquid Glass Dark",
	"Midnight Blue", "Obsidian White", "Crimson Dark", "Dark", "Darker",
	"Light", "Aqua", "Amethyst", "Rose", "Neon Red",
}

function Library:GetThemes()
	return table.clone(ThemeOrder)
end

function Library:AddTheme(name, theme, base)
	Themes[name] = derive(Themes[base or "Dark"], theme)
	table.insert(ThemeOrder, name)
end

-- Âm thanh UI mặc định (có thể thay bằng rbxassetid:// của bạn qua opts.Sounds)
Library.Sounds = {
	Click = "rbxasset://sounds/button.wav",
	Toggle = "rbxasset://sounds/switch.wav",
	Tab = "rbxasset://sounds/clickfast.wav",
	Tick = "rbxasset://sounds/clickfast.wav",
	Open = "rbxasset://sounds/snap.mp3",
	Notify = "rbxasset://sounds/electronicpingshort.wav",
}

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------
local function tween(inst, props, t, style, dir)
	local tw = TweenService:Create(
		inst,
		TweenInfo.new((t or 0.2) / math.max(Library.AnimationSpeed or 1, 0.05), style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

local function new(class, props)
	local inst = Instance.new(class)
	if inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end
	if inst:IsA("GuiButton") then
		inst.AutoButtonColor = false
		if inst:IsA("TextButton") then
			inst.Text = ""
		end
	end
	if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
		inst.Font = FONT
		inst.TextSize = 13
	end
	local parent = props.Parent
	for k, v in pairs(props) do
		if k ~= "Parent" then
			inst[k] = v
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

-- Signal nhỏ: Connect / Fire
local function newSignal()
	local handlers = {}
	local sig = {}
	function sig:Connect(fn)
		local h = { fn = fn }
		table.insert(handlers, h)
		return {
			Disconnect = function()
				h.fn = nil
				for i, x in ipairs(handlers) do
					if x == h then
						table.remove(handlers, i)
						break
					end
				end
			end,
		}
	end
	function sig:Fire(...)
		for _, h in ipairs(table.clone(handlers)) do
			if h.fn then
				task.spawn(h.fn, ...)
			end
		end
	end
	return sig
end

-- Giá trị "động" = function, hoặc bảng có chứa function
local function isDynamic(v)
	local t = type(v)
	if t == "function" then
		return true
	end
	if t == "table" then
		for _, x in ipairs(v) do
			if isDynamic(x) then
				return true
			end
		end
	end
	return false
end

-- Kéo theo trục X (dùng cho slider)
local function dragX(hit, onMove, onState)
	hit.InputBegan:Connect(function(input)
		if not isPress(input) then
			return
		end
		if onState then
			onState(true)
		end
		onMove(input.Position.X)
		local moveC, endC
		moveC = UserInputService.InputChanged:Connect(function(m)
			if isMove(m) then
				onMove(m.Position.X)
			end
		end)
		endC = UserInputService.InputEnded:Connect(function(e)
			if e.UserInputType == input.UserInputType then
				moveC:Disconnect()
				endC:Disconnect()
				if onState then
					onState(false)
				end
			end
		end)
	end)
end

------------------------------------------------------------------------
-- Window: text chạy theo code + flags + signal
------------------------------------------------------------------------
-- Biến string | number | function | bảng-nhiều-dòng thành string. Trả về (text, ok)
function Window:_resolve(v, depth)
	depth = depth or 0
	local t = type(v)
	if v == nil then
		return "", true
	elseif t == "function" then
		if depth > 4 then
			return "", true
		end
		local ok, r = pcall(v)
		if not ok then
			return tostring(r), false
		end
		return self:_resolve(r, depth + 1)
	elseif t == "table" then
		local parts, allOk = {}, true
		for _, x in ipairs(v) do
			local s, ok = self:_resolve(x, depth + 1)
			if not ok then
				allOk = false
			end
			table.insert(parts, s)
		end
		return table.concat(parts, "\n"), allOk
	end
	return tostring(v), true
end

-- Gắn text cho TextLabel/TextBox. Nếu value là function (hoặc bảng có function)
-- thì tự cập nhật mỗi `rate` giây (mặc định opts.LiveRate = 0.25s).
function Window:_text(inst, value, rate, onChange)
	local win = self
	local b = { inst = inst, rate = rate, acc = 0, registered = false }
	local function apply()
		local text, ok = win:_resolve(b.value)
		if not ok then
			if not b.warned then
				warn("[LiquidGlass] text function error: " .. tostring(text))
				b.warned = true
			end
			return
		end
		if text ~= b.last then
			b.last = text
			inst.Text = text
			if onChange then
				onChange(text)
			end
		end
	end
	b.apply = apply
	function b:Set(v, newRate)
		self.value = v
		self.dynamic = isDynamic(v)
		if newRate then
			self.rate = newRate
		end
		if self.dynamic and not self.registered then
			self.registered = true
			table.insert(win._live, self)
		end
		apply()
	end
	function b:Refresh()
		apply()
	end
	b:Set(value)
	return b
end

-- Auto save: lưu Flag + theme ra file (cần executor có writefile/readfile/isfile)
local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "ThanhDuyHub_Config.json"
local FS_OK = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"

function Window:_readConfig()
	if not FS_OK then
		return {}
	end
	local ok, data = pcall(function()
		if isfile(CONFIG_FILE) then
			return HttpService:JSONDecode(readfile(CONFIG_FILE))
		end
		return nil
	end)
	if ok and type(data) == "table" then
		return data
	end
	return {}
end

function Window:SaveConfig()
	if not FS_OK then
		return false
	end
	local data = {}
	for k, v in pairs(self.Flags) do
		local t = type(v)
		if type(k) == "string" and (t == "boolean" or t == "number" or t == "string") then
			data[k] = v
		end
	end
	data.__Theme = self.ThemeName
	return (pcall(writefile, CONFIG_FILE, HttpService:JSONEncode(data)))
end

function Window:_scheduleSave()
	if not self._autoSave then
		return
	end
	self._saveToken = (self._saveToken or 0) + 1
	local token = self._saveToken
	task.delay(0.6, function()
		if token == self._saveToken then
			self:SaveConfig()
		end
	end)
end

-- Flag: lưu giá trị + phát tín hiệu Changed (trừ khi silent)
function Window:_emit(flag, value, silent)
	if flag == nil then
		return
	end
	self.Flags[flag] = value
	if not silent and self._autoSave then
		self:_scheduleSave()
	end
	if not silent then
		self.Changed:Fire(flag, value)
	end
end

function Window:_register(flag, obj)
	if flag ~= nil then
		self._controls[flag] = obj
		local saved = self._saved and self._saved[flag]
		if saved ~= nil and obj.Set then
			task.defer(function()
				obj:Set(saved, false)
			end)
		end
	end
end

function Window:GetFlag(flag)
	return self.Flags[flag]
end

-- Điều khiển một thành phần bằng code: Window:SetFlag("feature", true)
function Window:SetFlag(flag, value, silent)
	local c = self._controls[flag]
	if c and c.Set then
		c:Set(value, silent)
		return true
	end
	return false
end

-- Lắng nghe một flag: Window:Listen("feature", function(value) ... end)
function Window:Listen(flag, fn)
	return self.Changed:Connect(function(f, v)
		if f == flag then
			fn(v)
		end
	end)
end

-- Việc cần dọn khi Window:Destroy()
function Window:OnDestroy(fn)
	table.insert(self._destroyHooks, fn)
end

------------------------------------------------------------------------
-- Window: theme / binding
------------------------------------------------------------------------
function Window:_val(key)
	local v = self.Theme[key]
	if v == nil then
		v = (key == "RimT") and 0.85 or 0
	end
	if not self.Acrylic and (key == "WindowT" or key == "PanelT") then
		return math.min(v, 0.04)
	end
	return v
end

function Window:_bind(inst, prop, key)
	table.insert(self._bound, { inst, prop, key })
	inst[prop] = self:_val(key)
	return inst
end

function Window:_hook(fn)
	table.insert(self._hooks, fn)
	fn(true)
end

-- Bán kính thật = bán kính gốc x hệ số R của theme (iOS 26 bo tròn hơn)
function Window:_cr(radius)
	return self.Rounded and radius * (self.Theme.R or 1) or 0
end

function Window:_corner(inst, radius)
	local c = new("UICorner", {
		CornerRadius = UDim.new(0, self:_cr(radius)),
		Parent = inst,
	})
	table.insert(self._corners, { c, radius })
	return c
end

function Window:_stroke(inst, thickness)
	local s = new("UIStroke", {
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = inst,
	})
	self:_bind(s, "Color", "Stroke")
	self:_bind(s, "Transparency", "StrokeT")
	-- viền sáng kiểu kính: sáng ở góc trên-trái và dưới-phải, mờ ở giữa
	new("UIGradient", {
		Rotation = 45,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0.65),
			NumberSequenceKeypoint.new(1, 0.1),
		}),
		Parent = s,
	})
	return s
end

function Window:_applyTheme()
	for i = #self._bound, 1, -1 do
		local b = self._bound[i]
		if b[1]:IsDescendantOf(self.Gui) then
			tween(b[1], { [b[2]] = self:_val(b[3]) }, 0.25)
		else
			table.remove(self._bound, i)
		end
	end
	for i = #self._corners, 1, -1 do
		local e = self._corners[i]
		if e[1].Parent then
			tween(e[1], { CornerRadius = UDim.new(0, self:_cr(e[2])) }, 0.35)
		else
			table.remove(self._corners, i)
		end
	end
	for _, fn in ipairs(self._hooks) do
		fn(false)
	end
end

function Window:_sound(name, speed)
	do return end -- UI sound đã tắt
	if not self.SoundEnabled then
		return
	end
	local snd = self._sounds[name]
	if not snd then
		return
	end
	local now = os.clock()
	if now - (self._lastSound[name] or 0) < 0.05 then
		return
	end
	self._lastSound[name] = now
	snd.PlaybackSpeed = speed or 1
	snd.TimePosition = 0
	snd:Play()
end

function Window:SetSoundVolume(v)
	self.SoundVolume = v
	for _, snd in pairs(self._sounds) do
		snd.Volume = v
	end
end

function Window:SetTheme(name)
	self:_scheduleSave()
	local th = Themes[name]
	if not th then
		return false
	end
	self.Theme, self.ThemeName = th, name
	self:_applyTheme()
	if th.Blur and self.BlurEnabled and not self._blurUser then
		self:SetBlur(true, th.Blur)
	else
		self:SetBlur(self.BlurEnabled)
	end
	return true
end

function Window:SetAcrylic(on)
	self.Acrylic = on and true or false
	self:_applyTheme()
end

function Window:SetRounded(on)
	self.Rounded = on and true or false
	for i = #self._corners, 1, -1 do
		local e = self._corners[i]
		if e[1].Parent then
			e[1].CornerRadius = UDim.new(0, self:_cr(e[2]))
		else
			table.remove(self._corners, i)
		end
	end
end

function Window:SetBlur(on, size)
	self.BlurEnabled = on and true or false
	self._blurSize = size or self._blurSize or 14
	local show = self.BlurEnabled and self.Visible
	if show then
		if not self._blur then
			self._blur = new("BlurEffect", { Name = "LiquidGlassBlur", Size = 0, Parent = Lighting })
		end
		tween(self._blur, { Size = self._blurSize }, 0.4)
	elseif self._blur then
		tween(self._blur, { Size = 0 }, 0.3)
	end
	-- Frost: thêm nhòe chiều sâu để ra cảm giác kính mờ dày như iOS 26
	local frost = self.Theme.Frost or 0
	if show and frost > 0 then
		if not self._dof then
			self._dof = new("DepthOfFieldEffect", {
				Name = "LiquidGlassFrost",
				FarIntensity = 0, NearIntensity = 0, FocusDistance = 0, InFocusRadius = 0,
				Parent = Lighting,
			})
		end
		tween(self._dof, { FarIntensity = frost }, 0.5)
	elseif self._dof then
		tween(self._dof, { FarIntensity = 0 }, 0.3)
	end
end

function Window:SetAnimationSpeed(v)
	Library.AnimationSpeed = math.clamp(tonumber(v) or 1, 0.1, 4)
end

function Window:SetScale(s)
	self.Scale = s
	if self.Visible then
		tween(self._uiScale, { Scale = s }, 0.2)
	end
end

function Window:SetFloatingButton(on)
	self.FloatingEnabled = on and true or false
	self._float.Visible = self.FloatingEnabled
end

------------------------------------------------------------------------
-- Window: vẽ icon nhỏ bằng Frame (không phụ thuộc asset)
------------------------------------------------------------------------
function Window:_bar(parent, size, pos, rot, key)
	local f = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = size,
		Position = pos,
		Rotation = rot or 0,
		Parent = parent,
	})
	self:_bind(f, "BackgroundColor3", key or "SubText")
	return f
end

function Window:_chevron(parent)
	local c = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(10, 14),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	self:_bar(c, UDim2.fromOffset(8, 2), UDim2.fromOffset(4, 4), 45)
	self:_bar(c, UDim2.fromOffset(8, 2), UDim2.fromOffset(4, 10), -45)
	return c
end

function Window:_check(parent)
	local c = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})
	self:_bar(c, UDim2.fromOffset(6, 2), UDim2.fromOffset(3, 9), 45, "Text")
	self:_bar(c, UDim2.fromOffset(11, 2), UDim2.fromOffset(8, 7), -50, "Text")
	return c
end

function Window:_searchIcon(parent)
	local c = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	local ring = new("Frame", { Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, Parent = c })
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ring })
	local s = new("UIStroke", { Thickness = 1.5, Parent = ring })
	self:_bind(s, "Color", "SubText")
	self:_bar(c, UDim2.fromOffset(5, 2), UDim2.fromOffset(11, 11), 45)
end

------------------------------------------------------------------------
-- Window: kéo thả
------------------------------------------------------------------------
function Window:_drag(handle, target, onTap, onState)
	handle.InputBegan:Connect(function(input)
		if not isPress(input) then
			return
		end
		local startPos = input.Position
		local origin = target.Position
		local moved = false
		local moveC, endC
		moveC = UserInputService.InputChanged:Connect(function(m)
			if isMove(m) then
				local d = m.Position - startPos
				if d.Magnitude > 5 and not moved then
					moved = true
					if onState then
						onState(true)
					end
				end
				if moved then
					target.Position = UDim2.new(
						origin.X.Scale, origin.X.Offset + d.X,
						origin.Y.Scale, origin.Y.Offset + d.Y
					)
				end
			end
		end)
		endC = UserInputService.InputEnded:Connect(function(e)
			if e.UserInputType == input.UserInputType then
				moveC:Disconnect()
				endC:Disconnect()
				if moved and onState then
					onState(false)
				end
				if not moved and onTap then
					onTap()
				end
			end
		end)
	end)
end

------------------------------------------------------------------------
-- Library:CreateWindow
------------------------------------------------------------------------
-- Chọn nơi đặt GUI: gethui() / CoreGui (executor) nếu có quyền, không thì PlayerGui
local function guiParent()
	local ok, h = pcall(function()
		return gethui and gethui()
	end)
	if ok and typeof(h) == "Instance" then
		return h
	end
	local okCG, cg = pcall(function()
		return game:GetService("CoreGui")
	end)
	if okCG and cg then
		local probe = Instance.new("Folder")
		local okSet = pcall(function()
			probe.Parent = cg
		end)
		local inside = okSet and probe.Parent == cg
		pcall(function()
			probe:Destroy()
		end)
		if inside then
			return cg
		end
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function avatarUrl()
	local plr = Players.LocalPlayer
	local uid = plr and plr.UserId or 1
	return "rbxthumb://type=AvatarHeadShot&id=" .. tostring(uid) .. "&w=150&h=150"
end

local function loopTween(inst, props, t, style)
	local tw = TweenService:Create(
		inst,
		TweenInfo.new(t, style or Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		props
	)
	tw:Play()
	return tw
end

function Window:_intro()
	local accent = self.Theme.Accent
	local overlay = new("Frame", {
		Name = "Intro",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(7, 5, 14),
		Active = true,
		ZIndex = 100,
		Parent = self.Gui,
	})
	new("UIGradient", {
		Rotation = 120,
		Color = ColorSequence.new(Color3.fromRGB(52, 22, 96), Color3.fromRGB(8, 6, 16)),
		Parent = overlay,
	})

	local glow = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.42),
		Size = UDim2.fromOffset(190, 190),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.85,
		ZIndex = 101,
		Parent = overlay,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = glow })

	local ring = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.42),
		Size = UDim2.fromOffset(124, 124),
		BackgroundTransparency = 1,
		ZIndex = 102,
		Parent = overlay,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ring })
	local ringStroke = new("UIStroke", { Thickness = 2.5, Color = accent, Transparency = 0.2, Parent = ring })

	local avatarWrap = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.42),
		Size = UDim2.fromOffset(104, 104),
		BackgroundTransparency = 1,
		ZIndex = 103,
		Parent = overlay,
	})
	local scale = new("UIScale", { Scale = 0, Parent = avatarWrap })
	local avatar = new("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = avatarUrl(),
		ZIndex = 103,
		Parent = avatarWrap,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = avatar })

	local title = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.42, 92),
		Size = UDim2.fromOffset(420, 36),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		TextSize = 28,
		Text = "ThanhDuyHub",
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = 1,
		ZIndex = 103,
		Parent = overlay,
	})
	new("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), accent), Parent = title })

	local status = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.42, 124),
		Size = UDim2.fromOffset(420, 18),
		BackgroundTransparency = 1,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(180, 170, 210),
		Text = "Đang khởi tạo...",
		TextTransparency = 1,
		ZIndex = 103,
		Parent = overlay,
	})

	local track = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.42, 150),
		Size = UDim2.fromOffset(240, 4),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.85,
		ZIndex = 103,
		Parent = overlay,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
	local fill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = accent,
		ZIndex = 104,
		Parent = track,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

	local pct = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.42, 168),
		Size = UDim2.fromOffset(240, 14),
		BackgroundTransparency = 1,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(180, 170, 210),
		Text = "0%",
		TextTransparency = 1,
		ZIndex = 103,
		Parent = overlay,
	})

	task.spawn(function()
		-- hiện dần: avatar nảy lên, chữ trượt vào, viền và glow thở
		tween(scale, { Scale = 1 }, 0.9, Enum.EasingStyle.Back)
		tween(title, { TextTransparency = 0 }, 0.6)
		tween(status, { TextTransparency = 0 }, 0.6)
		tween(pct, { TextTransparency = 0 }, 0.6)
		tween(title, { Position = UDim2.new(0.5, 0, 0.42, 88) }, 0.6)
		loopTween(glow, { Size = UDim2.fromOffset(230, 230), BackgroundTransparency = 0.94 }, 1.4)
		loopTween(ring, { Size = UDim2.fromOffset(136, 136) }, 1.4)
		task.wait(0.4)

		local steps = { "Đang tải giao diện...", "Đang nạp cấu hình...", "Đang áp dụng theme...", "Hoàn tất!" }
		for i, s in ipairs(steps) do
			status.Text = s
			local from = (i - 1) / #steps
			local target = i / #steps
			tween(fill, { Size = UDim2.fromScale(target, 1) }, 0.55)
			for step = 1, 18 do
				local p = from + (target - from) * (step / 18)
				pct.Text = tostring(math.floor(p * 100)) .. "%"
				task.wait(0.03)
			end
		end
		pct.Text = "100%"
		task.wait(0.3)

		-- thoát: mờ dần và phóng nhẹ
		tween(overlay, { BackgroundTransparency = 1 }, 0.6)
		tween(glow, { BackgroundTransparency = 1 }, 0.5)
		tween(ringStroke, { Transparency = 1 }, 0.5)
		tween(avatar, { ImageTransparency = 1 }, 0.5)
		tween(scale, { Scale = 1.15 }, 0.5)
		tween(title, { TextTransparency = 1 }, 0.4)
		tween(status, { TextTransparency = 1 }, 0.4)
		tween(pct, { TextTransparency = 1 }, 0.4)
		tween(track, { BackgroundTransparency = 1 }, 0.4)
		tween(fill, { BackgroundTransparency = 1 }, 0.4)
		task.wait(0.65)
		overlay:Destroy()
	end)
end

function Library:CreateWindow(opts)
	opts = opts or {}
	if opts.AnimationSpeed then
		Library.AnimationSpeed = math.clamp(tonumber(opts.AnimationSpeed) or 1, 0.1, 4)
	end
	local self = setmetatable({}, Window)
	self._bound, self._hooks, self._corners = {}, {}, {}
	self.Tabs, self.Flags, self._loops = {}, {}, {}
	self._conns, self._destroyHooks = {}, {}
	self._live, self._controls = {}, {}
	self.Changed = newSignal()
	self.Acrylic = opts.Acrylic ~= false
	self.Rounded = opts.Rounded ~= false
	self.ThemeName = Themes[opts.Theme or ""] and opts.Theme or "ThanhDuy Violet"
	self.Theme = Themes[self.ThemeName]
	self.ToggleKey = opts.ToggleKey or Enum.KeyCode.RightControl
	self.Visible = true
	self.Scale = 1
	self.BlurEnabled = false
	self.FloatingEnabled = opts.FloatingButton ~= false
	self._autoSave = opts.AutoSave ~= false
	self._saved = self._autoSave and self:_readConfig() or {}

	-- Tween lặp vô hạn (idle animation)
	local function loop(inst, props, t, style, reverse)
		local tw = TweenService:Create(
			inst,
			TweenInfo.new(t, style or Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, reverse or false),
			props
		)
		tw:Play()
		table.insert(self._loops, tw)
		return tw
	end

	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local want = opts.Size or Vector2.new(600, 440)
	local w, h = math.min(want.X, vp.X - 20), math.min(want.Y, vp.Y - 20)

	local parent = opts.Parent or guiParent()
	self.Gui = new("ScreenGui", {
		Name = "ThanhDuyHub",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
		Parent = parent,
	})

	-- Âm thanh UI
	self.SoundEnabled = false
	self.SoundVolume = opts.SoundVolume or 0.6
	self._sounds, self._lastSound = {}, {}
	local soundIds = {}
	if false then
		for k, v in pairs(opts.Sounds) do
			soundIds[k] = v
		end
	end
	for name, id in pairs(soundIds) do
		if id and id ~= "" then
			self._sounds[name] = new("Sound", {
				Name = "UI_" .. name,
				SoundId = id,
				Volume = self.SoundVolume,
				Parent = self.Gui,
			})
		end
	end

	-- Cửa sổ chính
	local main = new("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(w, h),
		Parent = self.Gui,
	})
	self.Main = main
	self._uiScale = new("UIScale", { Scale = 0.8, Parent = main })
	tween(self._uiScale, { Scale = 1 }, 0.8, Enum.EasingStyle.Elastic)
	self:_bind(main, "BackgroundColor3", "Window")
	self:_bind(main, "BackgroundTransparency", "WindowT")
	self:_corner(main, 24)
	local mainStroke = self:_stroke(main, 1.5)
	local sheen = new("UIGradient", { Rotation = 90, Parent = main })
	self:_hook(function()
		sheen.Transparency = NumberSequence.new(0, self.Theme.Sheen)
	end)

	-- Lớp "chất lỏng": quả cầu sáng trôi chậm, vệt sáng quét ngang, ánh sáng cạnh trên
	local liquid = new("CanvasGroup", {
		Name = "Liquid",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = main,
	})
	self:_corner(liquid, 24)
	local orbLayer = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = liquid })
	local function orb(size, from, to, t, key)
		local holder = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = from,
			Size = UDim2.fromOffset(size, size),
			BackgroundTransparency = 1,
			Parent = orbLayer,
		})
		for i, k in ipairs({ 1, 0.8, 0.6, 0.4 }) do
			local c = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(k, k),
				BackgroundTransparency = 0.94 - (i - 1) * 0.03,
				Parent = holder,
			})
			new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = c })
			self:_bind(c, "BackgroundColor3", key)
		end
		-- khối tròn trôi qua lại + phồng xẹp nhẹ
		loop(holder, { Position = to, Size = UDim2.fromOffset(size * 1.18, size * 1.18) }, t, Enum.EasingStyle.Sine, true)
	end

	-- Viền kính thứ hai bên trong (hiệu ứng viền kép của iOS 26), xoay ngược chiều viền ngoài
	local rim = new("Frame", {
		Size = UDim2.new(1, -6, 1, -6),
		Position = UDim2.fromOffset(3, 3),
		BackgroundTransparency = 1,
		Parent = main,
	})
	self:_corner(rim, 13)
	local rimStroke = new("UIStroke", {
		Thickness = 1.2,
		Color = Color3.new(1, 1, 1),
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = rim,
	})
	self:_bind(rimStroke, "Transparency", "RimT")
	local rimGrad = new("UIGradient", {
		Rotation = 225,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.45, 0.8),
			NumberSequenceKeypoint.new(1, 0.1),
		}),
		Parent = rimStroke,
	})
	loop(rimGrad, { Rotation = -135 }, 16, Enum.EasingStyle.Linear, false)

	-- Thanh tiêu đề
	local titlebar = new("Frame", {
		Name = "Titlebar",
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Parent = main,
	})
	local titleHolder = new("Frame", {
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(1, -140, 1, 0),
		BackgroundTransparency = 1,
		Parent = titlebar,
	})
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		Parent = titleHolder,
	})
	local titleLbl = new("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 16),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		TextSize = 12,
		Text = "ThanhDuyHub",
		Parent = titleHolder,
	})
	self:_bind(titleLbl, "TextColor3", "Text")
	local subLbl = new("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 16),
		BackgroundTransparency = 1,
		TextSize = 10,
		Text = opts.SubTitle or "",
		Parent = titleHolder,
	})
	self:_bind(subLbl, "TextColor3", "SubText")
	self:_drag(titlebar, main, nil, function(active)
		tween(self._uiScale, { Scale = self.Scale * (active and 1.025 or 1) }, 0.3, Enum.EasingStyle.Back)
	end)

	-- Nút điều khiển
	local ctl = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(100, 24),
		BackgroundTransparency = 1,
		Parent = titlebar,
	})
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 4),
		Parent = ctl,
	})
	local function makeCtl(order, draw, cb, danger)
		local b = new("TextButton", {
			LayoutOrder = order,
			Size = UDim2.fromOffset(30, 24),
			BackgroundTransparency = 1,
			Parent = ctl,
		})
		self:_corner(b, 8)
		self:_bind(b, "BackgroundColor3", "Text")
		draw(b)
		local cs = new("UIScale", { Scale = 0, Parent = b })
		task.delay(0.45 + order * 0.07, function()
			tween(cs, { Scale = 1 }, 0.5, Enum.EasingStyle.Back)
		end)
		b.MouseButton1Down:Connect(function()
			tween(cs, { Scale = 0.85 }, 0.08)
		end)
		b.MouseEnter:Connect(function()
			tween(cs, { Scale = 1.2 }, 0.18, Enum.EasingStyle.Back)
			if danger then
				b.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
				tween(b, { BackgroundTransparency = 0.2 }, 0.12)
			else
				tween(b, { BackgroundTransparency = 0.88 }, 0.12)
			end
		end)
		b.MouseLeave:Connect(function()
			tween(cs, { Scale = 1 }, 0.15)
			tween(b, { BackgroundTransparency = 1 }, 0.12)
		end)
		b.MouseButton1Click:Connect(function()
			self:_sound("Click")
			cb()
		end)
	end
	makeCtl(1, function(b)
		self:_bar(b, UDim2.fromOffset(10, 2), UDim2.fromScale(0.5, 0.5))
	end, function()
		self:Minimize()
	end)
	makeCtl(2, function(b)
		local sq = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,
			Parent = b,
		})
		local s = new("UIStroke", { Thickness = 1.5, Parent = sq })
		self:_bind(s, "Color", "SubText")
	end, function()
		self:Maximize()
	end)
	makeCtl(3, function(b)
		self:_bar(b, UDim2.fromOffset(13, 2), UDim2.fromScale(0.5, 0.5), 45)
		self:_bar(b, UDim2.fromOffset(13, 2), UDim2.fromScale(0.5, 0.5), -45)
	end, function()
		if opts.OnClose then
			task.spawn(opts.OnClose)
		end
		self:Close()
	end, true)

	-- Thân cửa sổ
	local body = new("CanvasGroup", {
		Name = "Body",
		Position = UDim2.fromOffset(0, 36),
		Size = UDim2.new(1, 0, 1, -36),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Parent = main,
	})
	self.Body = body

	-- Sidebar
	local side = new("Frame", {
		Position = UDim2.fromOffset(-14, 4),
		Size = UDim2.new(0, 150, 1, -14),
		BackgroundTransparency = 1,
		Parent = body,
	})

	-- Logo lớn phía trên ô tìm kiếm
	local logoBlock = new("Frame", { Size = UDim2.new(1, 0, 0, 80), BackgroundTransparency = 1, Parent = side })
	local glow = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 42),
		Size = UDim2.fromOffset(78, 78),
		BackgroundTransparency = 0.86,
		Parent = logoBlock,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 26), Parent = glow })
	self:_bind(glow, "BackgroundColor3", "Accent")
	local badge = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 42),
		Size = UDim2.fromOffset(64, 64),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = logoBlock,
	})
	self:_corner(badge, 20)
	local badgeGrad = new("UIGradient", { Rotation = 45, Parent = badge })
	local letter
	local logoImg = opts.Logo and tostring(opts.Logo) or avatarUrl()
	if logoImg:match("^%d+$") then
		logoImg = "rbxassetid://" .. logoImg
	end
	badge.BackgroundTransparency = 1
	local img = new("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = logoImg,
		ScaleType = Enum.ScaleType.Crop,
		Parent = badge,
	})
	self:_corner(img, 20)
	self:_hook(function()
		local a = self.Theme.Accent
		badgeGrad.Color = ColorSequence.new(a:Lerp(Color3.new(1, 1, 1), 0.2), a:Lerp(Color3.new(0, 0, 0), 0.4))
		if letter then
			local lum = a.R * 0.299 + a.G * 0.587 + a.B * 0.114
			letter.TextColor3 = lum > 0.75 and Color3.fromRGB(20, 20, 24) or Color3.new(1, 1, 1)
		end
	end)
	-- logo tương tác: rê chuột thì phóng to, bấm thì xoay một vòng
	local badgeScale = new("UIScale", { Parent = badge })
	local badgeBtn = new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = badge,
	})
	local spinning = false
	badgeBtn.MouseEnter:Connect(function()
		tween(badgeScale, { Scale = 1.1 }, 0.25, Enum.EasingStyle.Back)
	end)
	badgeBtn.MouseLeave:Connect(function()
		tween(badgeScale, { Scale = 1 }, 0.25)
	end)
	badgeBtn.MouseButton1Click:Connect(function()
		if spinning then
			return
		end
		spinning = true
		self:_sound("Click", 1.2)
		badge.Rotation = 0
		tween(badge, { Rotation = 360 }, 0.8, Enum.EasingStyle.Back)
		task.delay(0.85, function()
			badge.Rotation = 0
			spinning = false
		end)
	end)
	-- viền sáng quét quanh logo
	local ring = new("UIStroke", {
		Thickness = 2,
		Color = Color3.new(1, 1, 1),
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = badge,
	})
	local ringGrad = new("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = ring,
	})
	loop(ringGrad, { Rotation = 360 }, 3.5, Enum.EasingStyle.Linear, false)
	-- logo nhấp nhô nhẹ + glow thở
	loop(badge, { Position = UDim2.new(0.5, 0, 0, 38) }, 2.2, Enum.EasingStyle.Sine, true)
	loop(glow, {
		Position = UDim2.new(0.5, 0, 0, 38),
		Size = UDim2.fromOffset(88, 88),
		BackgroundTransparency = 0.93,
	}, 2.2, Enum.EasingStyle.Sine, true)
	local badgePop = new("UIScale", { Scale = 0, Parent = logoBlock })
	task.delay(0.25, function()
		tween(badgePop, { Scale = 1 }, 0.9, Enum.EasingStyle.Elastic)
	end)

	local searchBox = new("Frame", {
		Position = UDim2.fromOffset(0, 88),
		Size = UDim2.new(1, 0, 0, 30),
		Parent = side,
	})
	self:_bind(searchBox, "BackgroundColor3", "Surface")
	self:_bind(searchBox, "BackgroundTransparency", "SurfaceT")
	self:_corner(searchBox, 15)
	local searchStroke = self:_stroke(searchBox, 1)
	self:_searchIcon(searchBox)
	local search = new("TextBox", {
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -40, 1, 0),
		BackgroundTransparency = 1,
		PlaceholderText = "Search...",
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = LEFT,
		TextSize = 12,
		Parent = searchBox,
	})
	self:_bind(search, "TextColor3", "Text")
	self:_bind(search, "PlaceholderColor3", "SubText")
	self._search = search
	search.Focused:Connect(function()
		tween(searchStroke, { Color = self.Theme.Accent, Transparency = 0.05, Thickness = 2 }, 0.2)
		tween(searchBox, { BackgroundTransparency = math.max(self.Theme.SurfaceT - 0.15, 0) }, 0.2)
	end)
	search.FocusLost:Connect(function()
		tween(searchStroke, { Color = self.Theme.Stroke, Transparency = self:_val("StrokeT"), Thickness = 1 }, 0.25)
		tween(searchBox, { BackgroundTransparency = self:_val("SurfaceT") }, 0.25)
	end)
	search:GetPropertyChangedSignal("Text"):Connect(function()
		self:_applySearch()
	end)

	local tabScroll = new("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 128),
		Size = UDim2.new(1, 0, 1, -128),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = side,
	})
	-- thanh pill trượt giữa các tab
	local pill = new("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		Visible = false,
		ZIndex = 1,
		Parent = tabScroll,
	})
	self._pill = pill
	self:_bind(pill, "BackgroundColor3", "Surface")
	self:_corner(pill, 16)
	self:_stroke(pill, 1)
	self:_hook(function(instant)
		local t = self.Theme.SurfaceT * 0.55
		if instant then
			pill.BackgroundTransparency = t
		else
			tween(pill, { BackgroundTransparency = t }, 0.25)
		end
	end)
	self._tabList = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = tabScroll,
	})
	new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = self._tabList })

	-- Khu nội dung
	local content = new("Frame", {
		Position = UDim2.fromOffset(198, 0),
		Size = UDim2.new(1, -182, 1, -8),
		BackgroundTransparency = 1,
		Parent = body,
	})
	self._header = new("TextLabel", {
		Position = UDim2.fromOffset(4, 0),
		Size = UDim2.new(1, -4, 0, 44),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		TextSize = 26,
		TextXAlignment = LEFT,
		Text = "",
		Parent = content,
	})
	self:_bind(self._header, "TextColor3", "Text")
	self._pages = new("Frame", {
		Position = UDim2.fromOffset(0, 48),
		Size = UDim2.new(1, 0, 1, -48),
		BackgroundTransparency = 1,
		Parent = content,
	})

	-- Panel dropdown trượt từ cạnh phải
	self._blocker = new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 10,
		Parent = body,
	})
	self._blocker.MouseButton1Click:Connect(function()
		self:_closePanel()
	end)
	local panel = new("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 30, 0, 6),
		Size = UDim2.new(0, 215, 1, -14),
		Visible = false,
		ZIndex = 11,
		Parent = body,
	})
	self:_bind(panel, "BackgroundColor3", "Panel")
	self:_bind(panel, "BackgroundTransparency", "PanelT")
	self:_corner(panel, 12)
	self:_stroke(panel, 1)
	self._panelScale = new("UIScale", { Parent = panel })
	local plist = new("ScrollingFrame", {
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.new(1, -12, 1, -12),
		BackgroundTransparency = 1,
		ScrollBarThickness = 2,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ZIndex = 11,
		Parent = panel,
	})
	new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = plist })
	self._panel, self._plist = panel, plist

	-- Nút nổi
	-- Nút nổi: hiện icon của game đang chơi
	local float = new("ImageButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -24, 0.4, 0),
		Size = UDim2.fromOffset(52, 52),
		Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=150&h=150",
		ScaleType = Enum.ScaleType.Crop,
		Visible = self.FloatingEnabled,
		Parent = self.Gui,
	})
	self._float = float
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = float })
	self:_bind(float, "BackgroundColor3", "Window")
	self:_bind(float, "BackgroundTransparency", "WindowT")
	local floatStroke = self:_stroke(float, 1.5)
	self:_drag(float, float, function()
		self:Toggle()
	end)
	local fs = new("UIScale", { Scale = 0, Parent = float })
	task.delay(0.35, function()
		tween(fs, { Scale = 1 }, 0.5, Enum.EasingStyle.Back)
	end)
	float.MouseEnter:Connect(function()
		tween(fs, { Scale = 1.12 }, 0.2, Enum.EasingStyle.Back)
	end)
	float.MouseLeave:Connect(function()
		tween(fs, { Scale = 1 }, 0.2)
	end)
	float.MouseButton1Down:Connect(function()
		tween(fs, { Scale = 0.88 }, 0.1)
	end)
	float.MouseButton1Up:Connect(function()
		tween(fs, { Scale = 1.12 }, 0.2, Enum.EasingStyle.Back)
	end)
	loop(floatStroke, { Thickness = 3.2 }, 1.3, Enum.EasingStyle.Sine, true)

	-- Phím tắt ẩn/hiện
	self._keyConn = UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == self.ToggleKey then
			self:Toggle()
		end
	end)

	-- Animation mở cửa sổ: nền mờ dần, sidebar và nội dung trượt vào
	local wt = self:_val("WindowT")
	main.BackgroundTransparency = 1
	tween(main, { BackgroundTransparency = wt }, 0.45)
	task.delay(0.1, function()
		tween(body, { GroupTransparency = 0 }, 0.5)
		tween(side, { Position = UDim2.fromOffset(10, 4) }, 0.65, Enum.EasingStyle.Quint)
		tween(content, { Position = UDim2.fromOffset(172, 0) }, 0.65, Enum.EasingStyle.Quint)
	end)

	-- Vòng cập nhật text động (function) của các thành phần
	local liveRate = opts.LiveRate or 0.25
	table.insert(self._conns, RunService.Heartbeat:Connect(function(dt)
		if not self.Visible then
			return
		end
		local live = self._live
		for i = #live, 1, -1 do
			local b = live[i]
			if not b.inst:IsDescendantOf(self.Gui) then
				table.remove(live, i)
			elseif b.dynamic then
				b.acc = b.acc + dt
				if b.acc >= (b.rate or liveRate) then
					b.acc = 0
					b.apply()
				end
			end
		end
	end))

	-- khôi phục theme đã lưu
	if self._saved.__Theme and Themes[self._saved.__Theme] then
		self:SetTheme(self._saved.__Theme)
	end
	if opts.Blur == nil then
		opts.Blur = self.ThemeName == "ThanhDuy Violet" or string.sub(self.ThemeName, 1, 12) == "Liquid Glass" or string.sub(self.ThemeName, 1, 6) == "iOS 26"
	end
	if opts.Blur then
		self:SetBlur(true, opts.BlurSize or self.Theme.Blur)
	end
	if self._initMusicCtl then
		self:_initMusicCtl(opts)
	end
	return self
end

------------------------------------------------------------------------
-- Window: điều khiển
------------------------------------------------------------------------
function Window:Toggle(v)
	if v == nil then
		v = not self.Visible
	end
	self.Visible = v
	self:_sound("Open", v and 1 or 0.8)
	if v then
		self.Main.Visible = true
		self._uiScale.Scale = self.Scale * 0.92
		tween(self._uiScale, { Scale = self.Scale }, 0.25, Enum.EasingStyle.Back)
	else
		self:_closePanel()
		tween(self._uiScale, { Scale = self.Scale * 0.92 }, 0.15)
		task.delay(0.15, function()
			if not self.Visible then
				self.Main.Visible = false
			end
		end)
	end
	self:SetBlur(self.BlurEnabled)
end

function Window:Minimize(v)
	if v == nil then
		v = not self.Minimized
	end
	self.Minimized = v
	if v then
		self._restoreSize = self.Main.Size
		self:_closePanel()
		self.Body.Visible = false
		local s = self.Main.Size
		tween(self.Main, { Size = UDim2.new(s.X.Scale, s.X.Offset, 0, 36) }, 0.25)
	else
		tween(self.Main, { Size = self._restoreSize }, 0.25)
		task.delay(0.12, function()
			if not self.Minimized then
				self.Body.Visible = true
			end
		end)
	end
end

function Window:Maximize()
	if self.Minimized then
		return
	end
	local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	if self.Maximized then
		self.Maximized = false
		tween(self.Main, { Size = self._maxRestoreSize, Position = self._maxRestorePos }, 0.25)
	else
		self.Maximized = true
		self._maxRestoreSize, self._maxRestorePos = self.Main.Size, self.Main.Position
		tween(self.Main, {
			Size = UDim2.fromOffset((vp.X - 30) / self.Scale, (vp.Y - 30) / self.Scale),
			Position = UDim2.fromScale(0.5, 0.5),
		}, 0.25)
	end
end

function Window:Destroy()
	for _, tw in ipairs(self._loops) do
		tw:Cancel()
	end
	if self._keyConn then
		self._keyConn:Disconnect()
	end
	for _, c in ipairs(self._conns) do
		c:Disconnect()
	end
	if self._rippleConn then
		self._rippleConn:Disconnect()
	end
	for _, fn in ipairs(self._destroyHooks) do
		pcall(fn)
	end
	if self._blur then
		self._blur:Destroy()
	end
	if self._dof then
		self._dof:Destroy()
	end
	self.Gui:Destroy()
end

-- Đóng có animation (nút X dùng hàm này); Destroy() vẫn đóng ngay lập tức
function Window:Close()
	if self._closing then
		return
	end
	self._closing = true
	self:_closePanel()
	tween(self._uiScale, { Scale = self.Scale * 0.82 }, 0.32, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	tween(self.Main, { BackgroundTransparency = 1 }, 0.3)
	tween(self.Body, { GroupTransparency = 1 }, 0.22)
	tween(self._float, { BackgroundTransparency = 1 }, 0.2)
	task.delay(0.36 / math.max(Library.AnimationSpeed or 1, 0.05), function()
		self:Destroy()
	end)
end

------------------------------------------------------------------------
-- Window: panel dropdown
------------------------------------------------------------------------
function Window:_closePanel()
	if not self._panelOpen then
		return
	end
	self._panelOpen = false
	self._blocker.Visible = false
	local onClose = self._panelOnClose
	self._panelOnClose = nil
	if onClose then
		pcall(onClose)
	end
	tween(self._panel, { Position = UDim2.new(1, 30, 0, 6) }, 0.18)
	task.delay(0.18, function()
		if not self._panelOpen then
			self._panel.Visible = false
		end
	end)
end

function Window:_openPanel(cfg)
	self:_sound("Open")
	-- panel của dropdown khác đang mở: báo nó đóng trước
	local prevClose = self._panelOnClose
	self._panelOnClose = cfg.OnClose
	if prevClose then
		pcall(prevClose)
	end
	for _, c in ipairs(self._plist:GetChildren()) do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end
	local sel = {}
	if cfg.Multi then
		for _, v in ipairs(cfg.Selected or {}) do
			sel[v] = true
		end
	elseif cfg.Selected ~= nil then
		sel[cfg.Selected] = true
	end

	local refreshers = {}
	for i, opt in ipairs(cfg.Options) do
		local b = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 34),
			LayoutOrder = i,
			BackgroundTransparency = 1,
			ZIndex = 12,
			Parent = self._plist,
		})
		self:_bind(b, "BackgroundColor3", "Surface")
		self:_corner(b, 8)
		local bar = new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(3, 16),
			Visible = false,
			ZIndex = 13,
			Parent = b,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
		self:_bind(bar, "BackgroundColor3", "Accent")
		local lbl = new("TextLabel", {
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -44, 1, 0),
			BackgroundTransparency = 1,
			Font = FONT_MED,
			TextXAlignment = LEFT,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = tostring(opt),
			ZIndex = 13,
			Parent = b,
		})
		self:_bind(lbl, "TextColor3", "Text")
		lbl.TextTransparency = 1
		lbl.Position = UDim2.fromOffset(32, 0)
		task.delay((i - 1) * 0.025, function()
			tween(lbl, { TextTransparency = 0, Position = UDim2.fromOffset(14, 0) }, 0.3)
		end)
		local check = self:_check(b)
		for _, d in ipairs(check:GetChildren()) do
			d.ZIndex = 13
		end

		local function refresh()
			local on = sel[opt] == true
			bar.Visible = on
			check.Visible = on
		end
		refresh()
		table.insert(refreshers, refresh)

		b.MouseEnter:Connect(function()
			tween(b, { BackgroundTransparency = self.Theme.SurfaceT }, 0.12)
		end)
		b.MouseLeave:Connect(function()
			tween(b, { BackgroundTransparency = 1 }, 0.12)
		end)
		b.MouseButton1Click:Connect(function()
			self:_sound("Click")
			if cfg.Multi then
				sel[opt] = (not sel[opt]) or nil
				local list = {}
				for _, o in ipairs(cfg.Options) do
					if sel[o] then
						table.insert(list, o)
					end
				end
				for _, r in ipairs(refreshers) do
					r()
				end
				cfg.OnSelect(list)
			else
				sel = { [opt] = true }
				for _, r in ipairs(refreshers) do
					r()
				end
				cfg.OnSelect(opt)
				if cfg.CloseOnSelect ~= false then
					self:_closePanel()
				end
			end
		end)
	end

	self._panelOpen = true
	self._blocker.Visible = true
	self._panel.Visible = true
	self._panel.Position = UDim2.new(1, 30, 0, 6)
	self._panelScale.Scale = 0.92
	tween(self._panel, { Position = UDim2.new(1, -10, 0, 6) }, 0.45, Enum.EasingStyle.Back)
	tween(self._panelScale, { Scale = 1 }, 0.45, Enum.EasingStyle.Back)
end

------------------------------------------------------------------------
-- Window: thông báo
------------------------------------------------------------------------
function Window:Notify(o)
	if not self._notifyHolder then
		self._notifyHolder = new("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -16, 1, -16),
			Size = UDim2.new(0, 270, 1, -32),
			BackgroundTransparency = 1,
			Parent = self.Gui,
		})
		new("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = self._notifyHolder,
		})
	end
	local duration = o.Duration or 4
	self:_sound("Notify")
	local wrap = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = self._notifyHolder,
	})
	local f = new("Frame", {
		Position = UDim2.new(1, 40, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = self.Theme.Window,
		BackgroundTransparency = 1,
		Parent = wrap,
	})
	new("UICorner", { CornerRadius = UDim.new(0, self.Rounded and 12 or 0), Parent = f })
	local st = new("UIStroke", { Color = self.Theme.Accent, Transparency = 1, Parent = f })
	new("UIPadding", {
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
		Parent = f,
	})
	new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f })
	local t = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		TextXAlignment = LEFT,
		TextColor3 = self.Theme.Text,
		TextTransparency = 1,
		Text = self:_resolve(o.Title or "Notification"),
		Parent = f,
	})
	local d = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = LEFT,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = self.Theme.SubText,
		TextTransparency = 1,
		Text = self:_resolve(o.Content or ""),
		LayoutOrder = 2,
		Parent = f,
	})
	local bar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = self.Theme.Accent,
		BackgroundTransparency = 0.2,
		LayoutOrder = 3,
		Parent = f,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })

	tween(f, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = math.min(self.Theme.WindowT, 0.2) }, 0.45, Enum.EasingStyle.Back)
	tween(st, { Transparency = 0.5 }, 0.3)
	tween(t, { TextTransparency = 0 }, 0.3)
	tween(d, { TextTransparency = 0 }, 0.3)
	tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

	task.delay(duration, function()
		if not wrap.Parent then
			return
		end
		tween(f, { Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tween(st, { Transparency = 1 }, 0.25)
		tween(t, { TextTransparency = 1 }, 0.25)
		tween(d, { TextTransparency = 1 }, 0.25)
		tween(bar, { BackgroundTransparency = 1 }, 0.25)
		task.delay(0.35, function()
			wrap:Destroy()
		end)
	end)
end

------------------------------------------------------------------------
-- Window: tab
------------------------------------------------------------------------
function Window:_applySearch()
	local q = string.lower(self._search.Text or "")
	local tab = self.ActiveTab
	if not tab then
		return
	end
	for _, e in ipairs(tab.Elements) do
		if e.Hidden then
			e.Frame.Visible = false
		elseif q == "" then
			e.Frame.Visible = true
		elseif e.IsSection then
			e.Frame.Visible = false
		else
			local hay = e.Search or ""
			if e.Labels then
				for _, l in ipairs(e.Labels) do
					hay = hay .. " " .. l.Text
				end
			end
			e.Frame.Visible = string.find(string.lower(hay), q, 1, true) ~= nil
		end
	end
end

function Window:SelectTab(tab)
	local prev = self.ActiveTab
	self.ActiveTab = tab
	for _, t in ipairs(self.Tabs) do
		if t ~= tab then
			t.Group.Visible = false
		end
		t._render(false)
	end

	-- pill trượt tới tab được chọn
	local idx = table.find(self.Tabs, tab) or 1
	local prevIdx = prev and table.find(self.Tabs, prev) or idx
	local target = UDim2.fromOffset(0, (idx - 1) * 36)
	if prev == nil then
		self._pill.Position = target
		self._pill.Visible = true
	else
		tween(self._pill, { Position = target }, 0.4, Enum.EasingStyle.Back)
	end

	if prev ~= tab then
		if prev then
			self:_sound("Tab")
		end
		-- trang mới mờ dần + trượt lên
		tab.Group.Visible = true
		tab.Group.GroupTransparency = 1
		tab.Group.Position = UDim2.fromOffset(0, idx < prevIdx and -26 or 26)
		tween(tab.Group, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) }, 0.55, Enum.EasingStyle.Back)
		-- tiêu đề trượt vào
		self._header.Text = tab.Title
		self._header.TextTransparency = 1
		self._header.Position = UDim2.fromOffset(4, 12)
		tween(self._header, { TextTransparency = 0, Position = UDim2.fromOffset(4, 0) }, 0.4)
		-- chữ hiện dần như gõ
		task.spawn(function()
			local n = utf8.len(tab.Title) or #tab.Title
			for i = 0, n do
				if self.ActiveTab ~= tab then
					break
				end
				self._header.MaxVisibleGraphemes = i
				task.wait(0.03)
			end
			self._header.MaxVisibleGraphemes = -1
		end)
		-- các hàng bật lên lần lượt
		for k, e in ipairs(tab.Elements) do
			if e.Scale then
				e.Scale.Scale = 0.86
				task.delay(math.min(k, 12) * 0.04, function()
					tween(e.Scale, { Scale = 1 }, 0.55, Enum.EasingStyle.Back)
					-- sóng sáng chạy qua từng hàng
					if e.Flash then
						e.Flash.BackgroundTransparency = 0.82
						tween(e.Flash, { BackgroundTransparency = 1 }, 0.7)
					end
					if e.Stroke then
						e.Stroke.Color = self.Theme.Accent
						e.Stroke.Transparency = 0.15
						tween(e.Stroke, { Color = self.Theme.Stroke, Transparency = self:_val("StrokeT") }, 0.8)
					end
				end)
			end
		end
		-- icon nảy
		tab._iconHolder.Size = UDim2.fromOffset(8, 8)
		tween(tab._iconHolder, { Size = UDim2.fromOffset(16, 16) }, 0.45, Enum.EasingStyle.Back)
	end
	self:_applySearch()
end

function Window:AddTab(o)
	if type(o) == "string" then
		o = { Title = o }
	end
	local win = self
	local tab = setmetatable({ Window = self, Title = o.Title or "Tab", Elements = {} }, Tab)

	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		LayoutOrder = #self.Tabs + 1,
		BackgroundTransparency = 1,
		Parent = self._tabList,
	})
	local iconHolder = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 20, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundTransparency = 1,
		Parent = btn,
	})
	tab._iconHolder = iconHolder
	local icon
	if type(o.Icon) == "string" and (o.Icon:find("rbxasset") or o.Icon:match("^%d+$")) then
		local id = o.Icon:match("^%d+$") and ("rbxassetid://" .. o.Icon) or o.Icon
		icon = new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = id, Parent = iconHolder })
	else
		icon = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(6, 6),
			Parent = iconHolder,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = icon })
	end
	local lbl = new("TextLabel", {
		Position = UDim2.fromOffset(36, 0),
		Size = UDim2.new(1, -44, 1, 0),
		BackgroundTransparency = 1,
		Font = FONT_MED,
		TextXAlignment = LEFT,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = tab.Title,
		Parent = btn,
	})

	tab._render = function(instant)
		local active = win.ActiveTab == tab
		local th = win.Theme
		local col = active and th.Text or th.SubText
		local list = { { lbl, { TextColor3 = col } } }
		if icon:IsA("ImageLabel") then
			table.insert(list, { icon, { ImageColor3 = col } })
		else
			table.insert(list, { icon, { BackgroundColor3 = col } })
		end
		for _, p in ipairs(list) do
			if instant then
				for k, v in pairs(p[2]) do
					p[1][k] = v
				end
			else
				tween(p[1], p[2], 0.2)
			end
		end
	end
	self:_hook(tab._render)

	-- tab hiện ra lần lượt: chữ trượt vào, icon nảy lên
	lbl.TextTransparency = 1
	lbl.Position = UDim2.fromOffset(70, 0)
	local iconPop = new("UIScale", { Scale = 0, Parent = iconHolder })
	local introDelay = 0.35 + (#self.Tabs + 1) * 0.07
	task.delay(introDelay, function()
		tween(lbl, { TextTransparency = 0, Position = UDim2.fromOffset(36, 0) }, 0.55, Enum.EasingStyle.Back)
		tween(iconPop, { Scale = 1 }, 0.6, Enum.EasingStyle.Elastic)
	end)

	btn.MouseEnter:Connect(function()
		tween(lbl, { Position = UDim2.fromOffset(40, 0) }, 0.2)
		if win.ActiveTab ~= tab then
			tween(lbl, { TextColor3 = win.Theme.Text }, 0.15)
		end
	end)
	btn.MouseLeave:Connect(function()
		tween(lbl, { Position = UDim2.fromOffset(36, 0) }, 0.2)
		tab._render(false)
	end)

	tab.Group = new("CanvasGroup", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = self._pages,
	})
	tab.Page = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ScrollBarThickness = 2,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = tab.Group,
	})
	self:_bind(tab.Page, "ScrollBarImageColor3", "SubText")
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tab.Page })
	new("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 10), Parent = tab.Page })

	btn.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	table.insert(self.Tabs, tab)
	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end
	return tab
end

------------------------------------------------------------------------
-- Tab: các thành phần
------------------------------------------------------------------------
function Tab:_row(o, cfg)
	cfg = cfg or {}
	local win = self.Window
	local hasDesc = o.Description ~= nil and o.Description ~= ""
	local h = cfg.Height or (hasDesc and 56 or 46)
	local reserve = cfg.Reserve or 70

	local row = new("Frame", {
		Name = type(o.Title) == "string" and o.Title or "Row",
		Size = UDim2.new(1, 0, 0, h),
		LayoutOrder = #self.Elements + 1,
		Parent = self:_holder(),
	})
	win:_bind(row, "BackgroundColor3", "Surface")
	win:_bind(row, "BackgroundTransparency", "SurfaceT")
	win:_corner(row, 14)
	local rowStroke = win:_stroke(row, 1)
	local rowScale = new("UIScale", { Parent = row })

	local title = new("TextLabel", {
		Position = UDim2.fromOffset(14, cfg.TitleY or (hasDesc and 7 or 0)),
		Size = UDim2.new(1, -reserve, 0, cfg.TitleH or (hasDesc and 18 or h)),
		BackgroundTransparency = 1,
		Font = FONT_MED,
		TextXAlignment = LEFT,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row,
	})
	win:_bind(title, "TextColor3", "Text")
	local titleBind = win:_text(title, o.Title or "", o.RefreshRate)
	local descLabel, descBind
	if hasDesc then
		descLabel = new("TextLabel", {
			Position = UDim2.fromOffset(14, 25),
			Size = UDim2.new(1, -reserve, 0, 14),
			BackgroundTransparency = 1,
			TextSize = 11,
			TextXAlignment = LEFT,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})
		win:_bind(descLabel, "TextColor3", "SubText")
		descBind = win:_text(descLabel, o.Description, o.RefreshRate)
	end

	local click, flashRef
	if not cfg.NoClick then
		click = new("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 2,
			Parent = row,
		})
		local flash = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = row })
		win:_bind(flash, "BackgroundColor3", "Accent")
		win:_corner(flash, 14)
		local accentBar = new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 5, 0.5, 0),
			Size = UDim2.fromOffset(3, 0),
			Parent = row,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = accentBar })
		win:_bind(accentBar, "BackgroundColor3", "Accent")
		click.MouseEnter:Connect(function()
			tween(accentBar, { Size = UDim2.fromOffset(3, math.floor(h * 0.45)) }, 0.3, Enum.EasingStyle.Back)
		end)
		click.MouseLeave:Connect(function()
			tween(accentBar, { Size = UDim2.fromOffset(3, 0) }, 0.2)
		end)
		flashRef = flash
		click.MouseEnter:Connect(function()
			tween(row, { BackgroundTransparency = math.max(win.Theme.SurfaceT - 0.12, 0) }, 0.15)
			tween(rowStroke, { Color = win.Theme.Accent, Transparency = math.max(win.Theme.StrokeT - 0.4, 0) }, 0.15)
			tween(rowScale, { Scale = 1.012 }, 0.2, Enum.EasingStyle.Back)
		end)
		click.MouseLeave:Connect(function()
			tween(row, { BackgroundTransparency = win:_val("SurfaceT") }, 0.2)
			tween(rowStroke, { Color = win.Theme.Stroke, Transparency = win:_val("StrokeT"), Thickness = 1 }, 0.2)
			tween(rowScale, { Scale = 1 }, 0.2)
		end)
		click.MouseButton1Down:Connect(function()
			tween(rowStroke, { Thickness = 2 }, 0.08)
			tween(rowScale, { Scale = 0.97 }, 0.08)
		end)
		click.MouseButton1Up:Connect(function()
			tween(rowStroke, { Thickness = 1 }, 0.15)
			tween(rowScale, { Scale = 1.012 }, 0.25, Enum.EasingStyle.Back)
		end)
		click.MouseButton1Click:Connect(function()
			flash.BackgroundTransparency = 0.75
			tween(flash, { BackgroundTransparency = 1 }, 0.5)
			if not cfg.NoSound then
				win:_sound("Click")
			end
		end)
	end

	local entry = { Frame = row, Scale = rowScale, Flash = flashRef, Stroke = rowStroke, Labels = { title, descLabel }, Search = "" }
	table.insert(self.Elements, entry)

	-- API chung cho mọi thành phần dạng hàng (điều khiển bằng code)
	local tab = self
	local api = { Frame = row }
	function api:SetTitle(v)
		titleBind:Set(v)
	end
	function api:SetDescription(v)
		if descBind then
			descBind:Set(v)
		end
	end
	function api:Refresh()
		titleBind:Refresh()
		if descBind then
			descBind:Refresh()
		end
	end
	function api:SetVisible(v)
		entry.Hidden = not v
		row.Visible = v and true or false
	end
	function api:Destroy()
		tab:_removeElement(entry)
		row:Destroy()
	end
	return row, click, api
end

-- Gắn các hàm API chung vào một object (không ghi đè hàm đã có)
function Tab:_attach(obj, api)
	for k, v in pairs(api) do
		if obj[k] == nil then
			obj[k] = v
		end
	end
	return obj
end

function Tab:_removeElement(entry)
	for i, e in ipairs(self.Elements) do
		if e == entry then
			table.remove(self.Elements, i)
			break
		end
	end
end

-- Thêm thành phần theo tên (dùng khi dựng UI từ dữ liệu):  tab:Add("Toggle", {...})
function Tab:Add(kind, opts)
	local fn = self["Add" .. tostring(kind)]
	assert(type(fn) == "function", "[LiquidGlass] Unknown element '" .. tostring(kind) .. "' (did you Library:Use its module?)")
	return fn(self, opts or {})
end

------------------------------------------------------------------------
-- Tam giác (dùng clip một nửa hình thoi) + icon
------------------------------------------------------------------------
function Window:_triangle(parent, h, color)
	local clip = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(math.ceil(h / 2), h),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = parent,
	})
	local d = math.floor(h * 0.7071 + 0.5)
	local dia = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(0, math.floor(h / 2)),
		Size = UDim2.fromOffset(d, d),
		Rotation = 45,
		BackgroundColor3 = color,
		Parent = clip,
	})
	return clip, dia
end

------------------------------------------------------------------------
-- Mở rộng: cho module ngoài dùng chung tiện ích của library
------------------------------------------------------------------------
Library.Window, Library.Tab = Window, Tab
Library.Util = {
	new = new, tween = tween, dragX = dragX, isPress = isPress, isMove = isMove,
	FONT = FONT, FONT_MED = FONT_MED, FONT_BOLD = FONT_BOLD,
	LEFT = LEFT, RIGHT = RIGHT, CENTER = CENTER, C = C,
	newSignal = newSignal, isDynamic = isDynamic,
}

-- Nạp module chức năng:
--   Library:Use(require(Components.Toggle), require(Components.Slider))
--   Library:UseFolder(script.Parent.LiquidGlass.Components)   -- nạp cả thư mục
function Library:Use(...)
	for _, mod in ipairs({ ... }) do
		if type(mod) == "function" then
			mod(self)
		elseif type(mod) == "table" and mod.Init then
			mod.Init(self)
		end
	end
	return self
end

function Library:UseFolder(folder)
	for _, m in ipairs(folder:GetChildren()) do
		if m:IsA("ModuleScript") then
			self:Use(require(m))
		end
	end
	return self
end


------------------------------------------------------------------------
-- Thành phần dựng sẵn (gộp trong một file: dùng được cả executor lẫn Studio)
------------------------------------------------------------------------
do
local function __lg_Section(Library)

	local U = Library.Util
	local new, tween, dragX = U.new, U.tween, U.dragX
	local FONT, FONT_MED, FONT_BOLD = U.FONT, U.FONT_MED, U.FONT_BOLD
	local LEFT, RIGHT, CENTER = U.LEFT, U.RIGHT, U.CENTER
	local C = U.C
	local Window, Tab = Library.Window, Library.Tab

	function Tab:_holder()
		return self._group and self._group.Body or self.Page
	end

	-- Section = thẻ thu gọn được (giống mẫu): bấm tiêu đề để mở/đóng.
	-- Mọi thành phần thêm sau đó (Button, Toggle, Slider, Dropdown, Text...) nằm trong thẻ này.
	function Tab:AddSection(text, sopts)
		local win = self.Window
		sopts = type(sopts) == "table" and sopts or {}
		local hasDesc = sopts.Description ~= nil
		local open = sopts.Open ~= false

		local card = new("Frame", {
			Name = "Section",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = #self.Elements + 1,
			Parent = self.Page,
		})
		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = card })

		local head = new("TextButton", {
			Name = "Head",
			Size = UDim2.new(1, 0, 0, hasDesc and 52 or 42),
			LayoutOrder = 1,
			ZIndex = 2,
			BackgroundTransparency = 1,
			Parent = card,
		})
		win:_bind(head, "BackgroundColor3", "Surface")
		win:_bind(head, "BackgroundTransparency", "SurfaceT")
		win:_corner(head, 14)
		win:_stroke(head, 1)

		local function make(v)
			if U.isDynamic(v) then
				return function()
					return win:_resolve(v)
				end
			end
			return tostring(v)
		end

		local l = new("TextLabel", {
			Position = UDim2.fromOffset(14, hasDesc and 8 or 0),
			Size = UDim2.new(1, -50, 0, hasDesc and 18 or 42),
			BackgroundTransparency = 1,
			Font = FONT_BOLD,
			TextSize = 14,
			TextXAlignment = LEFT,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = head,
		})
		win:_bind(l, "TextColor3", "Text")
		local bind = win:_text(l, make(text))

		if hasDesc then
			local dl = new("TextLabel", {
				Position = UDim2.fromOffset(14, 27),
				Size = UDim2.new(1, -50, 0, 14),
				BackgroundTransparency = 1,
				TextSize = 11,
				TextXAlignment = LEFT,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = head,
			})
			win:_bind(dl, "TextColor3", "SubText")
			win:_text(dl, sopts.Description)
		end

		local chev = win:_chevron(head)
		chev.Rotation = open and 0 or -90

		local body = new("Frame", {
			Name = "Body",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Visible = open,
			Parent = card,
		})
		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = body })
		new("UIPadding", {
			PaddingTop = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			Parent = body,
		})

		local group = { Body = body, Card = card, Open = open }
		function group:SetOpen(v)
			self.Open = v and true or false
			body.Visible = self.Open
			tween(chev, { Rotation = self.Open and 0 or -90 }, 0.3)
		end
		head.MouseButton1Click:Connect(function()
			group:SetOpen(not group.Open)
		end)
		self._group = group

		local entry = { Frame = card, IsSection = true, Search = "" }
		table.insert(self.Elements, entry)

		local tab = self
		local obj = { Frame = card }
		function obj:SetText(v)
			bind:Set(make(v))
		end
		function obj:SetVisible(v)
			card.Visible = v and true or false
		end
		function obj:SetOpen(v)
			group:SetOpen(v)
		end
		function obj:Destroy()
			if tab._group == group then
				tab._group = nil
			end
			tab:_removeElement(entry)
			card:Destroy()
		end
		return obj
	end
end
__lg_Section(Library)
end
do
local function __lg_Label(Library)

	local U = Library.Util
	local new, tween, dragX = U.new, U.tween, U.dragX
	local FONT, FONT_MED, FONT_BOLD = U.FONT, U.FONT_MED, U.FONT_BOLD
	local LEFT, RIGHT, CENTER = U.LEFT, U.RIGHT, U.CENTER
	local C = U.C
	local Window, Tab = Library.Window, Library.Tab

	function Tab:AddLabel(o)
		if type(o) ~= "table" or (o.Title == nil and o[1] ~= nil) then
			o = { Title = o }
		end
		local _, _, api = self:_row(o, { NoClick = true })
		return api
	end
end
__lg_Label(Library)
end
do
local function __lg_Button(Library)

	local U = Library.Util
	local new, tween, dragX = U.new, U.tween, U.dragX
	local FONT, FONT_MED, FONT_BOLD = U.FONT, U.FONT_MED, U.FONT_BOLD
	local LEFT, RIGHT, CENTER = U.LEFT, U.RIGHT, U.CENTER
	local C = U.C
	local Window, Tab = Library.Window, Library.Tab

	function Tab:AddButton(o)
		local win = self.Window
		local _, click, api = self:_row(o, { Reserve = 50 })
		local chevron = win:_chevron(click.Parent)
		click.MouseEnter:Connect(function()
			tween(chevron, { Position = UDim2.new(1, -8, 0.5, 0) }, 0.25, Enum.EasingStyle.Back)
		end)
		click.MouseLeave:Connect(function()
			tween(chevron, { Position = UDim2.new(1, -14, 0.5, 0) }, 0.25)
		end)
		local obj = {}
		function obj:Fire()
			if o.Callback then
				task.spawn(o.Callback)
			end
		end
		function obj:SetCallback(fn)
			o.Callback = fn
		end
		click.MouseButton1Click:Connect(function()
			obj:Fire()
		end)
		return self:_attach(obj, api)
	end
end
__lg_Button(Library)
end
do
local function __lg_Toggle(Library)

	local U = Library.Util
	local new, tween, dragX = U.new, U.tween, U.dragX
	local FONT, FONT_MED, FONT_BOLD = U.FONT, U.FONT_MED, U.FONT_BOLD
	local LEFT, RIGHT, CENTER = U.LEFT, U.RIGHT, U.CENTER
	local C = U.C
	local Window, Tab = Library.Window, Library.Tab

	function Tab:AddToggle(o)
		local win = self.Window
		local _, click, api = self:_row(o, { NoSound = true })
		local row = click.Parent
		local obj = { Value = o.Default == true, Changed = U.newSignal() }

		local track = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(50, 30),
			Parent = row,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
		local knob = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(24, 24),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = track,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

		local function render(instant)
			local on, th = obj.Value, win.Theme
			local tp = { BackgroundColor3 = on and th.Accent or th.SubText, BackgroundTransparency = on and 0 or 0.65 }
			local kp = { Position = on and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 15, 0.5, 0) }
			if instant then
				for k, v in pairs(tp) do
					track[k] = v
				end
				knob.Position = kp.Position
			else
				tween(track, tp, 0.25)
				tween(knob, kp, 0.35, Enum.EasingStyle.Back)
				-- knob giãn ra rồi co lại như giọt chất lỏng
				tween(knob, { Size = UDim2.fromOffset(32, 24) }, 0.1)
				task.delay(0.1, function()
					tween(knob, { Size = UDim2.fromOffset(24, 24) }, 0.3, Enum.EasingStyle.Back)
				end)
				-- vòng sóng lan ra từ nút khi bật
				if on then
					local ring = new("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = kp.Position,
						Size = UDim2.fromOffset(16, 16),
						BackgroundTransparency = 1,
						Parent = track,
					})
					new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ring })
					local rs = new("UIStroke", { Thickness = 2, Color = th.Accent, Transparency = 0.2, Parent = ring })
					tween(ring, { Size = UDim2.fromOffset(52, 52) }, 0.55)
					tween(rs, { Transparency = 1 }, 0.55)
					task.delay(0.6, function()
						ring:Destroy()
					end)
				end
			end
		end
		win:_hook(render)

		function obj:Set(v, silent)
			self.Value = v and true or false
			render(false)
			if not silent then
				win:_sound("Toggle", self.Value and 1.12 or 0.9)
			end
			win:_emit(o.Flag, self.Value, silent)
			if not silent then
				self.Changed:Fire(self.Value)
				if o.Callback then
					task.spawn(o.Callback, self.Value)
				end
			end
		end
		function obj:OnChanged(fn)
			return self.Changed:Connect(fn)
		end
		click.MouseButton1Click:Connect(function()
			obj:Set(not obj.Value)
		end)
		win:_emit(o.Flag, obj.Value, true)
		win:_register(o.Flag, obj)
		return self:_attach(obj, api)
	end
end
__lg_Toggle(Library)
end
do
local function __lg_Slider(Library)

	local U = Library.Util
	local new, tween, dragX = U.new, U.tween, U.dragX
	local FONT, FONT_MED, FONT_BOLD = U.FONT, U.FONT_MED, U.FONT_BOLD
	local LEFT, RIGHT, CENTER = U.LEFT, U.RIGHT, U.CENTER
	local C = U.C
	local Window, Tab = Library.Window, Library.Tab

	function Tab:AddSlider(o)
		local win = self.Window
		local min, max, step = o.Min or 0, o.Max or 100, o.Step or 1
		local row, _, api = self:_row(o, { Height = 58, NoClick = true, TitleY = 8, TitleH = 18, Reserve = 90 })
		local obj = { Value = math.clamp(o.Default or min, min, max), Changed = U.newSignal() }

		local valLbl = new("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 8),
			Size = UDim2.fromOffset(70, 18),
			BackgroundTransparency = 1,
			TextXAlignment = RIGHT,
			Parent = row,
		})
		win:_bind(valLbl, "TextColor3", "SubText")
		local valScale = new("UIScale", { Parent = valLbl })

		local bar = new("Frame", {
			Position = UDim2.new(0, 14, 0, 40),
			Size = UDim2.new(1, -28, 0, 6),
			BackgroundTransparency = 0.8,
			Parent = row,
		})
		win:_bind(bar, "BackgroundColor3", "SubText")
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
		local fill = new("Frame", { Size = UDim2.fromScale(0, 1), Parent = bar })
		win:_bind(fill, "BackgroundColor3", "Accent")
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
		local knob = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = fill,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
		local hit = new("TextButton", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Parent = bar,
		})

		local function render()
			local a = (obj.Value - min) / (max - min)
			tween(fill, { Size = UDim2.fromScale(a, 1) }, 0.08, Enum.EasingStyle.Linear)
			valLbl.Text = tostring(math.round(obj.Value * 1000) / 1000)
			valScale.Scale = 1.25
			tween(valScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
		end
		function obj:Set(v, silent)
			v = math.clamp(math.floor((v - min) / step + 0.5) * step + min, min, max)
			if v == self.Value and not silent then
				return
			end
			self.Value = v
			render()
			if not silent then
				win:_sound("Tick", 0.8 + (v - min) / (max - min) * 0.6)
			end
			win:_emit(o.Flag, v, silent)
			if not silent then
				self.Changed:Fire(v)
				if o.Callback then
					task.spawn(o.Callback, v)
				end
			end
		end
		function obj:OnChanged(fn)
			return self.Changed:Connect(fn)
		end
		dragX(hit, function(x)
			local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			obj:Set(min + a * (max - min))
		end, function(active)
			tween(knob, { Size = active and UDim2.fromOffset(20, 20) or UDim2.fromOffset(14, 14) }, 0.2, Enum.EasingStyle.Back)
		end)
		render()
		win:_emit(o.Flag, obj.Value, true)
		win:_register(o.Flag, obj)
		return self:_attach(obj, api)
	end
end
__lg_Slider(Library)
end
do
local function __lg_Dropdown(Library)

	local U = Library.Util
	local new, tween, dragX = U.new, U.tween, U.dragX
	local FONT, FONT_MED, FONT_BOLD = U.FONT, U.FONT_MED, U.FONT_BOLD
	local LEFT, RIGHT, CENTER = U.LEFT, U.RIGHT, U.CENTER
	local C = U.C
	local Window, Tab = Library.Window, Library.Tab

	function Tab:AddDropdown(o)
		local win = self.Window
		local _, click, api = self:_row(o, { Reserve = 190 })
		local row = click.Parent

		-- Options có thể là bảng, hoặc function trả về bảng (đọc lại mỗi lần mở)
		local function getOptions()
			if type(o.Options) == "function" then
				local ok, r = pcall(o.Options)
				if ok and type(r) == "table" then
					return r
				end
				return {}
			end
			return o.Options or {}
		end

		local obj = { Options = getOptions(), Multi = o.Multi == true, Changed = U.newSignal() }
		if obj.Multi then
			obj.Value = o.Default or {}
		else
			obj.Value = o.Default or obj.Options[1]
		end

		local valLbl = new("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -36, 0.5, 0),
			Size = UDim2.fromOffset(140, 18),
			BackgroundTransparency = 1,
			TextSize = 12,
			TextXAlignment = RIGHT,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})
		win:_bind(valLbl, "TextColor3", "SubText")
		local plus = new("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			BackgroundTransparency = 1,
			Font = FONT_MED,
			TextSize = 18,
			Text = "+",
			Parent = row,
		})
		win:_bind(plus, "TextColor3", "Text")

		local function display()
			if obj.Multi then
				valLbl.Text = #obj.Value > 0 and table.concat(obj.Value, ", ") or "None"
			else
				valLbl.Text = tostring(obj.Value)
			end
		end
		function obj:Set(v, silent)
			self.Value = v
			display()
			win:_emit(o.Flag, v, silent)
			if not silent then
				self.Changed:Fire(v)
				if o.Callback then
					task.spawn(o.Callback, v)
				end
			end
		end
		function obj:SetOptions(list)
			self.Options = list
			o.Options = list
		end
		function obj:OnChanged(fn)
			return self.Changed:Connect(fn)
		end
		click.MouseButton1Click:Connect(function()
			if type(o.Options) == "function" then
				obj.Options = getOptions()
			end
			tween(plus, { Rotation = 45 }, 0.3, Enum.EasingStyle.Back)
			win:_openPanel({
				OnClose = function()
					tween(plus, { Rotation = 0 }, 0.25, Enum.EasingStyle.Back)
				end,
				Options = obj.Options,
				Multi = obj.Multi,
				Selected = obj.Value,
				CloseOnSelect = o.CloseOnSelect,
				OnSelect = function(v)
					obj:Set(v)
				end,
			})
		end)
		display()
		win:_emit(o.Flag, obj.Value, true)
		win:_register(o.Flag, obj)
		return self:_attach(obj, api)
	end
end
__lg_Dropdown(Library)
end
do
local function __lg_Input(Library)

	local U = Library.Util
	local new, tween, dragX = U.new, U.tween, U.dragX
	local FONT, FONT_MED, FONT_BOLD = U.FONT, U.FONT_MED, U.FONT_BOLD
	local LEFT, RIGHT, CENTER = U.LEFT, U.RIGHT, U.CENTER
	local C = U.C
	local Window, Tab = Library.Window, Library.Tab

	function Tab:AddInput(o)
		local win = self.Window
		local row, _, api = self:_row(o, { NoClick = true, Reserve = 170 })
		local obj = { Value = o.Default or "", Changed = U.newSignal() }
		local box = new("TextBox", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(140, 26),
			PlaceholderText = o.Placeholder or "Type here...",
			Text = obj.Value,
			ClearTextOnFocus = false,
			TextSize = 12,
			Parent = row,
		})
		win:_bind(box, "BackgroundColor3", "Surface")
		win:_bind(box, "BackgroundTransparency", "SurfaceT")
		win:_bind(box, "TextColor3", "Text")
		win:_bind(box, "PlaceholderColor3", "SubText")
		win:_corner(box, 8)
		win:_stroke(box, 1)
		function obj:Set(v, silent)
			self.Value = v
			box.Text = v
			win:_emit(o.Flag, v, silent)
			if not silent then
				self.Changed:Fire(v)
				if o.Callback then
					task.spawn(o.Callback, v)
				end
			end
		end
		function obj:SetPlaceholder(t)
			box.PlaceholderText = t
		end
		function obj:OnChanged(fn)
			return self.Changed:Connect(fn)
		end
		box.FocusLost:Connect(function()
			obj:Set(box.Text)
		end)
		win:_emit(o.Flag, obj.Value, true)
		win:_register(o.Flag, obj)
		return self:_attach(obj, api)
	end
end
__lg_Input(Library)
end
do
local function __lg_Paragraph(Library)

	local U = Library.Util
	local new, tween, dragX = U.new, U.tween, U.dragX
	local FONT, FONT_MED, FONT_BOLD = U.FONT, U.FONT_MED, U.FONT_BOLD
	local LEFT, RIGHT, CENTER = U.LEFT, U.RIGHT, U.CENTER
	local C = U.C
	local Window, Tab = Library.Window, Library.Tab

	------------------------------------------------------------------------
	-- Tab: Paragraph — nội dung chạy theo code
	--   Content: string | function() -> string | { "dòng 1", function() ... end, ... }
	--   Title:   string | function() -> string
	--   RefreshRate: số giây giữa mỗi lần cập nhật (mặc định opts.LiveRate = 0.25)
	------------------------------------------------------------------------
	function Tab:AddParagraph(o)
		local t = type(o)
		if t == "string" or t == "function" or (t == "table" and o.Content == nil and o.Title == nil and o[1] ~= nil) then
			o = { Content = o }
		end
		local win = self.Window
		local row = new("Frame", {
			Name = type(o.Title) == "string" and o.Title or "Paragraph",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = #self.Elements + 1,
			Parent = self:_holder(),
		})
		win:_bind(row, "BackgroundColor3", "Surface")
		win:_bind(row, "BackgroundTransparency", "SurfaceT")
		win:_corner(row, 10)
		win:_stroke(row, 1)
		local scale = new("UIScale", { Parent = row })
		new("UIPadding", {
			PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
			Parent = row,
		})
		new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row })

		local title = new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Font = FONT_BOLD,
			TextSize = 14,
			TextXAlignment = LEFT,
			LayoutOrder = 1,
			Visible = false,
			Parent = row,
		})
		win:_bind(title, "TextColor3", "Text")
		local titleBind = win:_text(title, o.Title or "", o.RefreshRate, function(text)
			title.Visible = text ~= ""
		end)

		local body = new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			TextSize = 12,
			LineHeight = 1.2,
			TextWrapped = true,
			RichText = true,
			TextXAlignment = LEFT,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = 2,
			Parent = row,
		})
		win:_bind(body, "TextColor3", "SubText")
		local bodyBind = win:_text(body, o.Content or "", o.RefreshRate)

		local entry = { Frame = row, Scale = scale, Labels = { title, body }, Search = "" }
		table.insert(self.Elements, entry)

		local tab = self
		local obj = { Frame = row }
		function obj:SetTitle(v)
			titleBind:Set(v)
		end
		-- v: string | function | bảng nhiều dòng; rate (tuỳ chọn) = giây giữa mỗi lần cập nhật
		function obj:SetContent(v, rate)
			bodyBind:Set(v, rate)
		end
		function obj:Append(text)
			local cur = body.Text
			bodyBind:Set(cur .. (cur ~= "" and "\n" or "") .. tostring(text))
		end
		function obj:Refresh()
			titleBind:Refresh()
			bodyBind:Refresh()
		end
		function obj:SetVisible(v)
			row.Visible = v and true or false
		end
		function obj:Destroy()
			tab:_removeElement(entry)
			row:Destroy()
		end
		-- gán trực tiếp bằng code:  para.Content = "..." | function | bảng ;  para.Title = ... ;  para.Visible = false
		return setmetatable({}, {
			__index = function(_, key)
				if key == "Content" then
					return body.Text
				elseif key == "Title" then
					return title.Text
				elseif key == "Visible" then
					return row.Visible
				end
				return obj[key]
			end,
			__newindex = function(_, key, v)
				if key == "Content" then
					obj:SetContent(v)
				elseif key == "Title" then
					obj:SetTitle(v)
				elseif key == "Visible" then
					obj:SetVisible(v)
				else
					rawset(obj, key, v)
				end
			end,
		})
	end
end
__lg_Paragraph(Library)
end
do
local function __lg_Cards(Library)

	local U = Library.Util
	local new, tween, dragX = U.new, U.tween, U.dragX
	local FONT, FONT_MED, FONT_BOLD = U.FONT, U.FONT_MED, U.FONT_BOLD
	local LEFT, RIGHT, CENTER = U.LEFT, U.RIGHT, U.CENTER
	local C = U.C
	local Window, Tab = Library.Window, Library.Tab
	local TweenService = game:GetService("TweenService")

	------------------------------------------------------------------------
	-- Cards: Discord / YouTube / TikTok (admin tự điền thông tin)
	------------------------------------------------------------------------
	local PLATFORMS = {
		Discord = { Color = C(88, 101, 242), Tag = "Discord Server" },
		YouTube = { Color = C(255, 40, 40), Tag = "YouTube Channel" },
		TikTok = { Color = C(254, 44, 85), Tag = "TikTok Account" },
	}

	local function buildUrl(platform, o)
		if o.Url and o.Url ~= "" then
			return o.Url
		end
		if platform == "Discord" and o.Invite then
			local code = tostring(o.Invite):gsub("^https?://[%w%.]*discord%.gg/", "")
			return "https://discord.gg/" .. code
		elseif platform == "YouTube" and o.Channel then
			local ch = tostring(o.Channel)
			if ch:find("^https?://") then
				return ch
			end
			if ch:sub(1, 1) ~= "@" then
				ch = "@" .. ch
			end
			return "https://www.youtube.com/" .. ch
		elseif platform == "TikTok" and o.Username then
			local u = tostring(o.Username):gsub("^@", "")
			return "https://www.tiktok.com/@" .. u
		end
		return ""
	end

	local function drawNote(parent, color, ox, oy)
		local f = new("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, ox, 0.5, oy),
			Size = UDim2.fromOffset(24, 28),
			Parent = parent,
		})
		new("Frame", { Position = UDim2.fromOffset(13, 2), Size = UDim2.fromOffset(4, 18), BackgroundColor3 = color, Parent = f })
		local head = new("Frame", { Position = UDim2.fromOffset(4, 15), Size = UDim2.fromOffset(11, 11), BackgroundColor3 = color, Parent = f })
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = head })
		local flag = new("Frame", { Position = UDim2.fromOffset(16, 4), Size = UDim2.fromOffset(8, 4), Rotation = 40, BackgroundColor3 = color, Parent = f })
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = flag })
	end

	function Tab:AddCard(o)
		local win = self.Window
		local platform = PLATFORMS[o.Platform] and o.Platform or "Discord"
		local plat = PLATFORMS[platform]
		local brand = o.Color or plat.Color
		local url = buildUrl(platform, o)

		local card = new("CanvasGroup", {
			Name = type(o.Name) == "string" and o.Name or plat.Tag,
			Size = UDim2.new(1, 0, 0, 126),
			LayoutOrder = #self.Elements + 1,
			Parent = self:_holder(),
		})
		win:_bind(card, "BackgroundColor3", "Surface")
		win:_bind(card, "BackgroundTransparency", "SurfaceT")
		win:_corner(card, 14)
		local cardStroke = win:_stroke(card, 1)
		local cardScale = new("UIScale", { Parent = card })

		-- ánh màu thương hiệu ở góc phải
		local glow = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -10, 0, 6),
			Size = UDim2.fromOffset(150, 150),
			BackgroundColor3 = brand,
			BackgroundTransparency = 0.85,
			Parent = card,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = glow })
		local glowTw = TweenService:Create(
			glow,
			TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Size = UDim2.fromOffset(190, 190), BackgroundTransparency = 0.92 }
		)
		glowTw:Play()
		table.insert(win._loops, glowTw)

		-- huy hiệu nền tảng
		local badge = new("Frame", {
			Position = UDim2.fromOffset(14, 14),
			Size = UDim2.fromOffset(52, 52),
			BackgroundColor3 = platform == "TikTok" and C(12, 12, 14) or brand,
			Parent = card,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 16), Parent = badge })
		if o.Image then
			local id = tostring(o.Image)
			if id:match("^%d+$") then
				id = "rbxassetid://" .. id
			end
			local img = new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = id, ScaleType = Enum.ScaleType.Crop, Parent = badge })
			new("UICorner", { CornerRadius = UDim.new(0, 16), Parent = img })
		elseif platform == "Discord" then
			local face = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(30, 22),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = badge,
			})
			new("UICorner", { CornerRadius = UDim.new(0, 11), Parent = face })
			for _, x in ipairs({ -6, 6 }) do
				local eye = new("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, x, 0.5, 1),
					Size = UDim2.fromOffset(5, 8),
					BackgroundColor3 = brand,
					Parent = face,
				})
				new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = eye })
			end
		elseif platform == "YouTube" then
			local rect = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(34, 24),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = badge,
			})
			new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = rect })
			win:_triangle(rect, 12, brand)
		else
			drawNote(badge, C(37, 244, 238), -2, -1)
			drawNote(badge, C(254, 44, 85), 2, 1)
			drawNote(badge, Color3.new(1, 1, 1), 0, 0)
		end
		local badgeScale = new("UIScale", { Parent = badge })
		local pulse = TweenService:Create(
			badgeScale,
			TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Scale = 1.07 }
		)
		pulse:Play()
		table.insert(win._loops, pulse)

		-- chữ
		local reserve = 92 + (o.Stat and 120 or 0)
		local nameLbl = new("TextLabel", {
			Position = UDim2.fromOffset(78, 14),
			Size = UDim2.new(1, -reserve, 0, 20),
			BackgroundTransparency = 1,
			Font = FONT_BOLD,
			TextSize = 15,
			TextXAlignment = LEFT,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = card,
		})
		win:_bind(nameLbl, "TextColor3", "Text")
		win:_text(nameLbl, o.Name or plat.Tag, o.RefreshRate)
		new("TextLabel", {
			Position = UDim2.fromOffset(78, 34),
			Size = UDim2.new(1, -92, 0, 14),
			BackgroundTransparency = 1,
			Font = FONT_MED,
			TextSize = 11,
			TextXAlignment = LEFT,
			TextColor3 = brand,
			Text = o.Tag or plat.Tag,
			Parent = card,
		})
		local desc = new("TextLabel", {
			Position = UDim2.fromOffset(78, 50),
			Size = UDim2.new(1, -92, 0, 28),
			BackgroundTransparency = 1,
			TextSize = 11,
			TextWrapped = true,
			TextXAlignment = LEFT,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = card,
		})
		win:_bind(desc, "TextColor3", "SubText")
		win:_text(desc, o.Description or "", o.RefreshRate)
		if o.Stat then
			local chip = new("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -14, 0, 14),
				Size = UDim2.fromOffset(0, 20),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = brand,
				BackgroundTransparency = 0.75,
				Parent = card,
			})
			new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = chip })
			new("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9), Parent = chip })
			local chipText = new("TextLabel", {
				Size = UDim2.fromOffset(0, 20),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Font = FONT_MED,
				TextSize = 11,
				Parent = chip,
			})
			win:_bind(chipText, "TextColor3", "Text")
			win:_text(chipText, o.Stat, o.RefreshRate)
		end

		-- ô link + nút copy
		local box = new("TextBox", {
			Position = UDim2.fromOffset(14, 88),
			Size = UDim2.new(1, -118, 0, 26),
			ClearTextOnFocus = false,
			TextSize = 11,
			TextXAlignment = LEFT,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = url,
			PlaceholderText = "Link not set",
			Parent = card,
		})
		win:_bind(box, "BackgroundColor3", "Surface")
		win:_bind(box, "BackgroundTransparency", "SurfaceT")
		win:_bind(box, "TextColor3", "Text")
		win:_bind(box, "PlaceholderColor3", "SubText")
		win:_corner(box, 8)
		new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = box })
		box.FocusLost:Connect(function()
			box.Text = url
		end)

		local copyBtn = new("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 88),
			Size = UDim2.fromOffset(88, 26),
			BackgroundColor3 = brand,
			Font = FONT_BOLD,
			TextSize = 12,
			TextColor3 = Color3.new(1, 1, 1),
			Text = "Copy Link",
			Parent = card,
		})
		win:_corner(copyBtn, 8)
		local btnScale = new("UIScale", { Parent = copyBtn })
		copyBtn.MouseEnter:Connect(function()
			tween(btnScale, { Scale = 1.06 }, 0.15, Enum.EasingStyle.Back)
		end)
		copyBtn.MouseLeave:Connect(function()
			tween(btnScale, { Scale = 1 }, 0.15)
		end)
		copyBtn.MouseButton1Down:Connect(function()
			tween(btnScale, { Scale = 0.92 }, 0.08)
		end)
		copyBtn.MouseButton1Click:Connect(function()
			win:_sound("Click")
			local fn
			pcall(function()
				fn = setclipboard or toclipboard or (syn and syn.write_clipboard)
			end)
			local ok = false
			if fn and url ~= "" then
				ok = pcall(fn, url)
			end
			if ok then
				copyBtn.Text = "Copied!"
				win:Notify({ Title = plat.Tag, Content = "Link copied to clipboard." })
				task.delay(1.6, function()
					if copyBtn.Parent then
						copyBtn.Text = "Copy Link"
					end
				end)
			elseif url ~= "" then
				box:CaptureFocus()
				win:Notify({ Title = plat.Tag, Content = "Select the link and copy it (Ctrl + C)." })
			end
			if o.Callback then
				task.spawn(o.Callback, url)
			end
		end)

		-- hover
		card.MouseEnter:Connect(function()
			tween(cardScale, { Scale = 1.02 }, 0.25, Enum.EasingStyle.Back)
			tween(cardStroke, { Color = brand, Transparency = 0.1 }, 0.2)
		end)
		card.MouseLeave:Connect(function()
			tween(cardScale, { Scale = 1 }, 0.2)
			tween(cardStroke, { Color = win.Theme.Stroke, Transparency = win:_val("StrokeT") }, 0.25)
		end)

		-- vệt sáng quét qua card

		table.insert(self.Elements, {
			Frame = card,
			Scale = cardScale,
			Labels = { nameLbl, desc },
			Search = string.lower(plat.Tag),
		})
		return { Frame = card, Url = url }
	end

	local function cardWith(platform, statKey, statSuffix)
		return function(self, o)
			o = table.clone(o or {})
			o.Platform = platform
			if o[statKey] and not o.Stat then
				local src = o[statKey]
				if type(src) == "function" then
					o.Stat = function()
						return tostring(src()) .. " " .. statSuffix
					end
				else
					o.Stat = tostring(src) .. " " .. statSuffix
				end
			end
			return self:AddCard(o)
		end
	end
	Tab.AddDiscord = cardWith("Discord", "Members", "members")
	Tab.AddYouTube = cardWith("YouTube", "Subscribers", "subscribers")
	Tab.AddTikTok = cardWith("TikTok", "Followers", "followers")


end
__lg_Cards(Library)
end
do
local function __lg_Music(Library)

	local U = Library.Util
	local new, tween, dragX = U.new, U.tween, U.dragX
	local FONT, FONT_MED, FONT_BOLD = U.FONT, U.FONT_MED, U.FONT_BOLD
	local LEFT, RIGHT, CENTER = U.LEFT, U.RIGHT, U.CENTER
	local C = U.C
	local Window, Tab = Library.Window, Library.Tab
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local SoundService = game:GetService("SoundService")
	local MarketplaceService = game:GetService("MarketplaceService")

	local function contrastOn(color)
		local lum = color.R * 0.299 + color.G * 0.587 + color.B * 0.114
		return lum > 0.72 and Color3.fromRGB(20, 20, 24) or Color3.new(1, 1, 1)
	end

	------------------------------------------------------------------------
	-- Music
	------------------------------------------------------------------------
	local function parseAudioId(v)
		if v == nil then
			return nil
		end
		local id = tostring(v):match("%d+")
		if not id or #id < 5 then
			return nil
		end
		return "rbxassetid://" .. id, id
	end

	local function fmtTime(t)
		t = math.max(math.floor(t or 0), 0)
		return string.format("%d:%02d", math.floor(t / 60), t % 60)
	end

	function Window:_musicChanged()
		for _, fn in ipairs(self._musicListeners or {}) do
			pcall(fn)
		end
	end

	function Window:_ensureMusic()
		if not self._music then
			local snd = new("Sound", {
				Name = "LiquidGlassMusic",
				Volume = self.MusicVolume or 0.5,
				Looped = true,
				Parent = SoundService,
			})
			self._music = { Sound = snd }
			self:OnDestroy(function()
				snd:Destroy()
			end)
		end
		return self._music
	end

	function Window:PlayMusic(raw, name, source)
		local asset, id = parseAudioId(raw)
		if not asset then
			self:Notify({ Title = "Music", Content = "Invalid music ID. Please enter a number." })
			return false
		end
		local m = self:_ensureMusic()
		m.Token = (m.Token or 0) + 1
		local token = m.Token
		m.Sound:Stop()
		m.Sound.SoundId = asset
		m.Source, m.Id = source or "user", id
		m.Name = name or ("Audio " .. id)
		m.Sound.TimePosition = 0
		m.Sound:Play()
		self:_musicChanged()

		if not name then
			task.spawn(function()
				local ok, info = pcall(function()
					return MarketplaceService:GetProductInfo(tonumber(id))
				end)
				if ok and info and info.Name and m.Token == token then
					m.Name = info.Name
					self:_musicChanged()
				end
			end)
		end
		task.spawn(function()
			local t0 = os.clock()
			while os.clock() - t0 < 8 and m.Token == token do
				if m.Sound.IsLoaded and m.Sound.TimeLength > 0 then
					return
				end
				task.wait(0.25)
			end
			if m.Token == token and not (m.Sound.IsLoaded and m.Sound.TimeLength > 0) then
				self:StopMusic()
				self:Notify({ Title = "Music", Content = "Can't play this ID (private, removed or not allowed)." })
			end
		end)
		return true
	end

	function Window:StopMusic()
		local m = self._music
		if not m then
			return
		end
		m.Token = (m.Token or 0) + 1
		m.Sound:Stop()
		m.Source, m.Name = nil, nil
		self:_musicChanged()
	end

	function Window:PauseMusic()
		if self._music and self._music.Source then
			self._music.Sound:Pause()
			self:_musicChanged()
		end
	end

	function Window:ResumeMusic()
		if self._music and self._music.Source then
			self._music.Sound:Resume()
			self:_musicChanged()
		end
	end

	function Window:SetMusicVolume(v)
		self.MusicVolume = v
		if self._music then
			self._music.Sound.Volume = v
		end
	end


	function Window:SetMusicLoop(on)
		local m = self:_ensureMusic()
		m.Sound.Looped = on and true or false
	end

	-- Nhạc admin chạy theo code: bảng, hoặc function trả về bảng (đọc lại liên tục)
	local function normTracks(win, src)
		if type(src) == "function" then
			local ok, r = pcall(src)
			src = ok and r or nil
		end
		local out = {}
		if type(src) == "table" then
			if src.Id then
				src = { src }
			end
			for _, t in ipairs(src) do
				if type(t) == "table" and t.Id then
					local nm = t.Name ~= nil and (win:_resolve(t.Name)) or nil
					if nm == nil or nm == "" then
						nm = "Admin track " .. (#out + 1)
					end
					table.insert(out, { Name = nm, Id = t.Id })
				end
			end
		end
		return out
	end

	local function trackSig(list)
		local parts = {}
		for _, t in ipairs(list) do
			table.insert(parts, tostring(t.Name) .. ":" .. tostring(t.Id))
		end
		return table.concat(parts, "|")
	end

	function Window:GetAdminTracks()
		return normTracks(self, self._adminSource)
	end

	function Window:_adminChanged()
		local list = self:GetAdminTracks()
		self._adminSig = trackSig(list)
		if self.AdminChanged then
			self.AdminChanged:Fire(list)
		end
	end

	function Window:SetAdminTracks(src)
		self._adminSource = src
		self._adminIndex = 1
		self:_adminChanged()
	end

	function Window:AddAdminTrack(name, id)
		local s = self._adminSource
		if type(s) ~= "table" then
			s = {}
		elseif s.Id then
			s = { s }
		end
		table.insert(s, { Name = name, Id = id })
		self._adminSource = s
		self:_adminChanged()
	end

	function Window:RemoveAdminTrack(which)
		local s = self._adminSource
		if type(s) ~= "table" then
			return false
		end
		if s.Id then
			s = { s }
		end
		local idx = type(which) == "number" and which or nil
		if type(which) == "string" then
			for i, t in ipairs(s) do
				if (self:_resolve(t.Name)) == which then
					idx = i
					break
				end
			end
		end
		if idx and s[idx] then
			table.remove(s, idx)
			self._adminSource = s
			self:_adminChanged()
			return true
		end
		return false
	end

	-- which: số thứ tự hoặc tên bài; bỏ trống = bài đang chọn
	function Window:PlayAdmin(which)
		local list = self:GetAdminTracks()
		local idx = type(which) == "number" and which or nil
		if type(which) == "string" then
			for i, t in ipairs(list) do
				if t.Name == which then
					idx = i
					break
				end
			end
		end
		idx = idx or self._adminIndex or 1
		local tr = list[idx]
		if not tr then
			self:Notify({ Title = "Music", Content = "The owner hasn't set any music yet." })
			return false
		end
		self._adminIndex = idx
		return self:PlayMusic(tr.Id, tr.Name, "admin")
	end

	-- Gọi từ CreateWindow: tạo Window.Music (điều khiển nhạc bằng code) + tín hiệu AdminChanged
	function Window:_initMusicCtl(opts)
		local win = self
		self._musicListeners = self._musicListeners or {}
		self._adminIndex = 1
		self.AdminChanged = U.newSignal()
		if opts and opts.AdminTracks ~= nil then
			self._adminSource = opts.AdminTracks
		end
		self._adminSig = trackSig(self:GetAdminTracks())
		local acc = 0
		table.insert(self._conns, RunService.Heartbeat:Connect(function(dt)
			if type(win._adminSource) ~= "function" then
				return
			end
			acc = acc + dt
			if acc < 0.5 then
				return
			end
			acc = 0
			local sig = trackSig(win:GetAdminTracks())
			if sig ~= win._adminSig then
				win._adminSig = sig
				win.AdminChanged:Fire(win:GetAdminTracks())
			end
		end))
		self.Music = {
			SetAdminTracks = function(_, src) win:SetAdminTracks(src) end,
			AddAdminTrack = function(_, name, id) win:AddAdminTrack(name, id) end,
			RemoveAdminTrack = function(_, which) return win:RemoveAdminTrack(which) end,
			GetAdminTracks = function() return win:GetAdminTracks() end,
			PlayAdmin = function(_, which) return win:PlayAdmin(which) end,
			Play = function(_, id, name) return win:PlayMusic(id, name, "user") end,
			Pause = function() win:PauseMusic() end,
			Resume = function() win:ResumeMusic() end,
			Stop = function() win:StopMusic() end,
			SetVolume = function(_, v) win:SetMusicVolume(v) end,
			SetLoop = function(_, on) win:SetMusicLoop(on) end,
			OnAdminChanged = function(_, fn) return win.AdminChanged:Connect(fn) end,
		}
	end

	--[[
		Tab:AddMusicPlayer({
			AdminTracks = {...} | function,   -- tuỳ chọn: đặt nhạc admin
			Volume = 0.5, Loop = true,
			OnEmptyPlay = function() end,     -- khi bấm Play lúc chưa có nhạc (mặc định: phát bài admin đầu tiên)
			OnStateChange = function(mm) end, -- mỗi khi trạng thái nhạc đổi (mm.Source = "admin" | "user" | nil)
		})
	]]
	function Tab:AddMusicPlayer(o)
		o = o or {}
		local win = self.Window
		local tab = self
		if o.AdminTracks ~= nil then
			win:SetAdminTracks(o.AdminTracks)
		end
		win.MusicVolume = o.Volume or win.MusicVolume or 0.5
		local m = win:_ensureMusic()
		m.Sound.Volume = win.MusicVolume
		m.Sound.Looped = o.Loop ~= false

		-- Thẻ player
		local card = new("Frame", {
			Name = "MusicPlayer",
			Size = UDim2.new(1, 0, 0, 142),
			LayoutOrder = #self.Elements + 1,
			Parent = self:_holder(),
		})
		win:_bind(card, "BackgroundColor3", "Surface")
		win:_bind(card, "BackgroundTransparency", "SurfaceT")
		win:_corner(card, 12)
		win:_stroke(card, 1)
		local cardScale = new("UIScale", { Parent = card })
		table.insert(self.Elements, { Frame = card, Scale = cardScale, Search = "music player now playing" })

		local artGlow = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(48, 48),
			Size = UDim2.fromOffset(84, 84),
			BackgroundTransparency = 0.88,
			Parent = card,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = artGlow })
		win:_bind(artGlow, "BackgroundColor3", "Accent")
		local art = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(48, 48),
			Size = UDim2.fromOffset(64, 64),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = card,
		})
		win:_corner(art, 18)
		local artGrad = new("UIGradient", { Rotation = 45, Parent = art })
		local artScale = new("UIScale", { Parent = art })
		local artRing = new("UIStroke", { Thickness = 2, Color = Color3.new(1, 1, 1), Parent = art })
		local artRingGrad = new("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = artRing,
		})
		local ringTw = TweenService:Create(artRingGrad, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), { Rotation = 360 })
		ringTw:Play()
		table.insert(win._loops, ringTw)

		local artBars = {}
		for i = 1, 4 do
			artBars[i] = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0, 12 + (i - 1) * 13, 1, -14),
				Size = UDim2.fromOffset(6, 10),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = art,
			})
			new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = artBars[i] })
		end

		local nameLbl = new("TextLabel", {
			Position = UDim2.fromOffset(92, 14),
			Size = UDim2.new(1, -106, 0, 20),
			BackgroundTransparency = 1,
			Font = FONT_BOLD,
			TextSize = 15,
			TextXAlignment = LEFT,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = "Nothing playing",
			Parent = card,
		})
		win:_bind(nameLbl, "TextColor3", "Text")
		local srcLbl = new("TextLabel", {
			Position = UDim2.fromOffset(92, 34),
			Size = UDim2.new(1, -106, 0, 14),
			BackgroundTransparency = 1,
			TextSize = 11,
			TextXAlignment = LEFT,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = "Pick admin music or enter your own ID",
			Parent = card,
		})
		win:_bind(srcLbl, "TextColor3", "SubText")

		local barBg = new("Frame", {
			Position = UDim2.fromOffset(92, 62),
			Size = UDim2.new(1, -106, 0, 6),
			BackgroundTransparency = 0.8,
			Parent = card,
		})
		win:_bind(barBg, "BackgroundColor3", "SubText")
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barBg })
		local barFill = new("Frame", { Size = UDim2.fromScale(0, 1), Parent = barBg })
		win:_bind(barFill, "BackgroundColor3", "Accent")
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barFill })
		local barKnob = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromOffset(10, 10),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = barFill,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barKnob })
		local barHit = new("TextButton", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			Parent = barBg,
		})
		local tCur = new("TextLabel", {
			Position = UDim2.fromOffset(92, 74),
			Size = UDim2.fromOffset(60, 14),
			BackgroundTransparency = 1,
			TextSize = 10,
			TextXAlignment = LEFT,
			Text = "0:00",
			Parent = card,
		})
		win:_bind(tCur, "TextColor3", "SubText")
		local tEnd = new("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 74),
			Size = UDim2.fromOffset(60, 14),
			BackgroundTransparency = 1,
			TextSize = 10,
			TextXAlignment = RIGHT,
			Text = "0:00",
			Parent = card,
		})
		win:_bind(tEnd, "TextColor3", "SubText")

		-- nút play/pause + stop
		local playBtn = new("TextButton", {
			Position = UDim2.fromOffset(92, 98),
			Size = UDim2.fromOffset(34, 34),
			Parent = card,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = playBtn })
		win:_bind(playBtn, "BackgroundColor3", "Accent")
		local playScale = new("UIScale", { Parent = playBtn })
		local playIcon = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(16, 16),
			BackgroundTransparency = 1,
			Parent = playBtn,
		})
		local _, triDia = win:_triangle(playIcon, 14, Color3.new(1, 1, 1))
		local pauseIcon = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = playBtn,
		})
		local pauseBars = {}
		for i = 1, 2 do
			pauseBars[i] = new("Frame", {
				Position = UDim2.fromOffset((i - 1) * 9 + 1, 0),
				Size = UDim2.fromOffset(4, 14),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = pauseIcon,
			})
		end

		local stopBtn = new("TextButton", {
			Position = UDim2.fromOffset(134, 98),
			Size = UDim2.fromOffset(34, 34),
			Parent = card,
		})
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = stopBtn })
		win:_bind(stopBtn, "BackgroundColor3", "Surface")
		win:_bind(stopBtn, "BackgroundTransparency", "SurfaceT")
		win:_stroke(stopBtn, 1)
		local stopScale = new("UIScale", { Parent = stopBtn })
		local stopIcon = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(10, 10),
			Parent = stopBtn,
		})
		win:_bind(stopIcon, "BackgroundColor3", "Text")
		new("UICorner", { CornerRadius = UDim.new(0, 2), Parent = stopIcon })

		for _, pair in ipairs({ { playBtn, playScale }, { stopBtn, stopScale } }) do
			pair[1].MouseEnter:Connect(function()
				tween(pair[2], { Scale = 1.12 }, 0.18, Enum.EasingStyle.Back)
			end)
			pair[1].MouseLeave:Connect(function()
				tween(pair[2], { Scale = 1 }, 0.18)
			end)
			pair[1].MouseButton1Down:Connect(function()
				tween(pair[2], { Scale = 0.9 }, 0.08)
			end)
			pair[1].MouseButton1Up:Connect(function()
				tween(pair[2], { Scale = 1.12 }, 0.15, Enum.EasingStyle.Back)
			end)
		end

		-- thanh visualizer
		local N = 20
		local viz = new("Frame", {
			Position = UDim2.fromOffset(182, 100),
			Size = UDim2.new(1, -196, 0, 30),
			BackgroundTransparency = 1,
			Parent = card,
		})
		local vbars, smooth = {}, {}
		for i = 1, N do
			local b = new("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new((i - 1) / N, 0, 1, 0),
				Size = UDim2.new(1 / N, -3, 0.08, 0),
				Parent = viz,
			})
			new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = b })
			win:_bind(b, "BackgroundColor3", "Accent")
			vbars[i], smooth[i] = b, 0.08
		end

		-- màu theo theme
		win:_hook(function()
			local a = win.Theme.Accent
			artGrad.Color = ColorSequence.new(a:Lerp(Color3.new(1, 1, 1), 0.2), a:Lerp(Color3.new(0, 0, 0), 0.4))
			local ic = contrastOn(a)
			triDia.BackgroundColor3 = ic
			for _, b in ipairs(pauseBars) do
				b.BackgroundColor3 = ic
			end
			for _, b in ipairs(artBars) do
				b.BackgroundColor3 = ic
			end
		end)

		local function refresh()
			local mm = win._music
			local active = mm.Source ~= nil
			local paused = mm.Sound.IsPaused
			nameLbl.Text = active and (mm.Name or "Playing") or "Nothing playing"
			if active then
				srcLbl.Text = (mm.Source == "admin" and "Admin music" or "Your music") .. (paused and "  •  Paused" or "")
			else
				srcLbl.Text = "Pick admin music or enter your own ID"
			end
			local playing = active and not paused
			playIcon.Visible = not playing
			pauseIcon.Visible = playing
			if o.OnStateChange then
				pcall(o.OnStateChange, mm)
			end
		end
		win._musicListeners = win._musicListeners or {}
		table.insert(win._musicListeners, refresh)

		playBtn.MouseButton1Click:Connect(function()
			win:_sound("Click")
			local mm = win._music
			if mm.Source == nil then
				if o.OnEmptyPlay then
					pcall(o.OnEmptyPlay)
				elseif #win:GetAdminTracks() > 0 then
					win:PlayAdmin()
				else
					win:Notify({ Title = "Music", Content = "Enter a music ID to start." })
				end
			elseif mm.Sound.IsPaused then
				win:ResumeMusic()
			else
				win:PauseMusic()
			end
		end)
		stopBtn.MouseButton1Click:Connect(function()
			win:_sound("Click")
			win:StopMusic()
		end)
		dragX(barHit, function(x)
			local mm = win._music
			if mm.Source and mm.Sound.TimeLength > 0 then
				local a = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
				mm.Sound.TimePosition = a * mm.Sound.TimeLength
			end
		end, function(active)
			tween(barKnob, { Size = active and UDim2.fromOffset(15, 15) or UDim2.fromOffset(10, 10) }, 0.15, Enum.EasingStyle.Back)
		end)

		-- visualizer phản ứng theo độ lớn âm thanh thật
		local clock = 0
		table.insert(win._conns, RunService.Heartbeat:Connect(function(dt)
			if not card:IsDescendantOf(win.Gui) or not tab.Group.Visible or not win.Main.Visible then
				return
			end
			local snd = win._music.Sound
			local playing = win._music.Source ~= nil and snd.IsPlaying
			local loud = playing and math.clamp(snd.PlaybackLoudness / 450, 0, 1) or 0
			clock = clock + dt
			for i = 1, N do
				local target = playing and (0.1 + loud * (0.3 + 0.7 * math.abs(math.sin(clock * 5 + i * 0.9)))) or 0.06
				smooth[i] = smooth[i] + (target - smooth[i]) * math.min(dt * 14, 1)
				vbars[i].Size = UDim2.new(1 / N, -3, math.clamp(smooth[i], 0.05, 1), 0)
			end
			for i = 1, 4 do
				local h = 8 + (playing and loud * (0.4 + 0.6 * math.abs(math.sin(clock * 6 + i * 1.7))) * 30 or 0)
				artBars[i].Size = UDim2.fromOffset(6, h)
			end
			artScale.Scale = 1 + loud * 0.09
			if win._music.Source and snd.TimeLength > 0 then
				barFill.Size = UDim2.fromScale(math.clamp(snd.TimePosition / snd.TimeLength, 0, 1), 1)
				local a, b = fmtTime(snd.TimePosition), fmtTime(snd.TimeLength)
				if tCur.Text ~= a then
					tCur.Text = a
				end
				if tEnd.Text ~= b then
					tEnd.Text = b
				end
			elseif not win._music.Source then
				barFill.Size = UDim2.fromScale(0, 1)
				tCur.Text, tEnd.Text = "0:00", "0:00"
			end
		end))


		refresh()
		return card
	end

end
__lg_Music(Library)
end


-- Tab dựng sẵn (gọi khi cần): Window:AddSettingsTab / AddMusicTab / AddInfoTab
do
local function __lg_Presets(Library)

	local U = Library.Util
	local new, tween, dragX = U.new, U.tween, U.dragX
	local FONT, FONT_MED, FONT_BOLD = U.FONT, U.FONT_MED, U.FONT_BOLD
	local LEFT, RIGHT, CENTER = U.LEFT, U.RIGHT, U.CENTER
	local C = U.C
	local Window, Tab = Library.Window, Library.Tab
	------------------------------------------------------------------------
	-- Tab Settings dựng sẵn (Interface)
	------------------------------------------------------------------------
	function Window:AddSettingsTab()
		local tab = self:AddTab({ Title = "Settings" })
		tab:AddSection("Interface")
		tab:AddToggle({
			Title = "Liquid Glass Blur",
			Default = self.BlurEnabled,
			Callback = function(v)
				self:SetBlur(v)
			end,
		})
		tab:AddToggle({
			Title = "Acrylic Transparency",
			Default = self.Acrylic,
			Callback = function(v)
				self:SetAcrylic(v)
			end,
		})
		tab:AddDropdown({
			Title = "Select Theme",
			Description = "Choose the UI theme",
			Options = Library:GetThemes(),
			Default = self.ThemeName,
			CloseOnSelect = false,
			Callback = function(v)
				self:SetTheme(v)
			end,
		})
		tab:AddToggle({
			Title = "Rounded Corners",
			Description = "Round or square the UI corners",
			Default = self.Rounded,
			Callback = function(v)
				self:SetRounded(v)
			end,
		})
		tab:AddToggle({
			Title = "Floating Button",
			Description = "Round button to show / hide the menu",
			Default = self.FloatingEnabled,
			Callback = function(v)
				self:SetFloatingButton(v)
			end,
		})
		tab:AddSlider({
			Title = "Blur Size",
			Min = 0, Max = 40, Default = self._blurSize or 14,
			Callback = function(v)
				self._blurSize = v
				self._blurUser = true
				if self.BlurEnabled then
					self:SetBlur(true, v)
				end
			end,
		})
		tab:AddSlider({
			Title = "UI Scale",
			Min = 0.7, Max = 1.3, Step = 0.05, Default = 1,
			Callback = function(v)
				self:SetScale(v)
			end,
		})
		tab:AddSlider({
			Title = "Animation Speed",
			Description = "Lower = slower and smoother, higher = snappier",
			Min = 0.5, Max = 2, Step = 0.1, Default = Library.AnimationSpeed or 1,
			Callback = function(v)
				self:SetAnimationSpeed(v)
			end,
		})
		return tab
	end
	------------------------------------------------------------------------
	-- Tab Music dựng sẵn: ghép từ AddMusicPlayer + AddDropdown/AddToggle/AddInput/AddSlider
	--   Nhạc admin (do admin đặt, đổi được bằng code) + nhạc người dùng (nhập ID là phát)
	------------------------------------------------------------------------
	function Window:AddMusicTab(o)
		o = o or {}
		local tab = self:AddTab({ Title = o.TabTitle or "Music" })
		tab:AddMusic(o)
		return tab
	end

	function Tab:AddMusic(o)
		o = o or {}
		local win = self.Window
		if o.AdminTracks ~= nil then
			win:SetAdminTracks(o.AdminTracks)
		end
		win.MusicVolume = o.Volume or win.MusicVolume or 0.5
		local m = win:_ensureMusic()
		m.Sound.Volume = win.MusicVolume
		m.Sound.Looped = o.Loop ~= false

		local adminToggle, adminDrop
		local adminIndex = 1
		local function names()
			local out = {}
			for _, t in ipairs(win:GetAdminTracks()) do
				table.insert(out, t.Name)
			end
			return out
		end
		local function firstName()
			return names()[1] or "-"
		end

		self:AddSection(o.Title or "Music")
		self:AddMusicPlayer({
			Volume = o.Volume,
			Loop = o.Loop,
			OnEmptyPlay = function()
				if adminToggle then
					adminToggle:Set(true)
				end
			end,
			OnStateChange = function(mm)
				if mm.Source == "admin" and win._adminIndex and win._adminIndex ~= adminIndex then
					adminIndex = win._adminIndex
					if adminDrop then
						adminDrop:Set(names()[adminIndex] or "-", true)
					end
				end
				if adminToggle and adminToggle.Value ~= (mm.Source == "admin") then
					adminToggle:Set(mm.Source == "admin", true)
				end
			end,
		})

		self:AddSection(o.AdminTitle or "Admin Music")
		adminDrop = self:AddDropdown({
			Title = "Admin Track",
			Description = "Tracks chosen by the owner",
			Options = names, -- đọc lại mỗi lần mở
			Default = firstName(),
			Callback = function(v)
				for i, n in ipairs(names()) do
					if n == v then
						adminIndex = i
					end
				end
				if adminToggle and adminToggle.Value then
					win:PlayAdmin(adminIndex)
				end
			end,
		})
		adminDrop:SetVisible(#names() > 1)
		adminToggle = self:AddToggle({
			Title = "Play Admin Music",
			Description = function()
				local t = win:GetAdminTracks()[adminIndex]
				if t then
					return "Owner's pick: " .. t.Name
				end
				return "The owner hasn't set any music yet"
			end,
			Callback = function(v)
				if v then
					if not win:GetAdminTracks()[adminIndex] then
						win:Notify({ Title = "Music", Content = "The owner hasn't set any music yet." })
						adminToggle:Set(false, true)
						return
					end
					win:PlayAdmin(adminIndex)
				elseif win._music.Source == "admin" then
					win:StopMusic()
				end
			end,
		})
		-- admin đổi danh sách bằng code -> UI tự cập nhật
		win.AdminChanged:Connect(function(list)
			if adminIndex > #list then
				adminIndex = math.max(#list, 1)
			end
			adminDrop:SetVisible(#list > 1)
			adminDrop:Set(list[adminIndex] and list[adminIndex].Name or "-", true)
		end)

		self:AddSection(o.UserTitle or "Your Music")
		self:AddInput({
			Title = "Music ID",
			Description = "Enter a Roblox audio ID — it plays right away",
			Placeholder = "e.g. 1843463175",
			Callback = function(text)
				if text and text ~= "" then
					win:PlayMusic(text, nil, "user")
				end
			end,
		})
		self:AddSlider({
			Title = "Music Volume",
			Min = 0, Max = 100, Default = math.floor(win.MusicVolume * 100),
			Callback = function(v)
				win:SetMusicVolume(v / 100)
			end,
		})
		self:AddToggle({
			Title = "Loop",
			Description = "Repeat the current track",
			Default = o.Loop ~= false,
			Callback = function(v)
				win:SetMusicLoop(v)
			end,
		})

		if o.AutoPlayAdmin and #win:GetAdminTracks() > 0 then
			task.defer(function()
				adminToggle:Set(true)
			end)
		end
		self.Music = win.Music
		return win.Music
	end

	-- Tab "Info" dựng sẵn: admin điền thông tin nào thì hiện card đó
	function Window:AddInfoTab(o)
		o = o or {}
		local tab = self:AddTab({ Title = o.Title or "Info" })
		if o.About then
			tab:AddSection("About")
			tab:AddParagraph(o.About)
		end
		if o.Discord or o.YouTube or o.TikTok then
			tab:AddSection(o.CommunityTitle or "Community")
		end
		local function add(method, v)
			if not v then
				return
			end
			if v[1] ~= nil then
				for _, x in ipairs(v) do
					tab[method](tab, x)
				end
			else
				tab[method](tab, v)
			end
		end
		add("AddDiscord", o.Discord)
		add("AddYouTube", o.YouTube)
		add("AddTikTok", o.TikTok)
		return tab
	end
end
__lg_Presets(Library)
end

------------------------------------------------------------------------
-- KeySystem kiểu LiquidGlass
-- Gọi TRƯỚC Library:CreateWindow. Hàm dừng (yield) tới khi nhập đúng key rồi trả về key.
--   local key = Library:RequireKey({
--       Title = "ThanhDuy Hub",
--       Note = "Nhập key để tiếp tục",
--       Key = "ABC-123",                             -- string hoặc bảng {"KEY1", "KEY2"}
--       KeyValidator = function(k) return true end,  -- tuỳ chọn, thay cho Key
--       URL = "https://...",                         -- tuỳ chọn, nút "Lấy key" (copy link)
--       SaveKey = true,                              -- lưu key đúng để lần sau bỏ qua
--       Folder = "ThanhDuyHub",                      -- thư mục lưu key
--       Theme = "ThanhDuy Violet",                   -- tuỳ chọn, dùng theme của thư viện
--   })
------------------------------------------------------------------------
function Library:RequireKey(opts)
	opts = opts or {}
	local theme = Themes[opts.Theme or ""] or Themes["ThanhDuy Violet"]
	local R = theme.R or 1
	local ERROR_C = C(255, 96, 112)
	local OK_C = C(90, 220, 150)
	local folder = opts.Folder or "ThanhDuyHub"
	local uid = tostring(Players.LocalPlayer and Players.LocalPlayer.UserId or "default")
	local keyFile = folder .. "/" .. uid .. ".key"
	local canFile = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
	local saveKey = canFile and opts.SaveKey ~= false

	local function clean(s)
		return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
	end

	local function check(key)
		if key == "" then return false end
		if opts.KeyValidator then
			local ok, res = pcall(opts.KeyValidator, key)
			return ok and res == true
		end
		if type(opts.Key) == "table" then
			return table.find(opts.Key, key) ~= nil
		end
		return opts.Key ~= nil and tostring(opts.Key) == key
	end

	-- Key đã lưu và còn đúng thì bỏ qua màn hình nhập
	if saveKey then
		local savedKey
		pcall(function()
			if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(folder) then
				makefolder(folder)
			end
			if isfile(keyFile) then
				local saved = clean(readfile(keyFile))
				if check(saved) then
					savedKey = saved
				end
			end
		end)
		if savedKey then
			return savedKey
		end
	end

	-- Giao diện
	local gui = new("ScreenGui", {
		Name = "ThanhDuyHub_KeySystem",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 10000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = guiParent(),
	})

	local dim = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = C(0, 0, 0),
		BackgroundTransparency = 1,
		Parent = gui,
	})

	local card = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(340, 320),
		BackgroundColor3 = theme.Window,
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = dim,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 24 * R), Parent = card })
	local cardScale = new("UIScale", { Scale = 0.88, Parent = card })

	-- Viền kính sáng hai góc (cùng kiểu với các cửa sổ khác)
	local cardStroke = new("UIStroke", {
		Color = theme.Stroke,
		Transparency = 1,
		Thickness = 1.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = card,
	})
	new("UIGradient", {
		Rotation = 45,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0.65),
			NumberSequenceKeypoint.new(1, 0.1),
		}),
		Parent = cardStroke,
	})

	-- Lớp phản sáng phía trên
	local sheen = new("Frame", {
		Size = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = C(255, 255, 255),
		BackgroundTransparency = 1 - (theme.Sheen or 0.2) * 0.4,
		ZIndex = 2,
		Parent = card,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 24 * R), Parent = sheen })
	new("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = sheen,
	})

	-- Icon tròn
	local iconCircle = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 24),
		Size = UDim2.fromOffset(60, 60),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0.75,
		ZIndex = 3,
		Parent = card,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = iconCircle })
	local iconStroke = new("UIStroke", {
		Color = theme.Accent,
		Transparency = 0.4,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = iconCircle,
	})
	new("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "KEY",
		Font = FONT_BOLD,
		TextSize = 14,
		TextColor3 = theme.Accent,
		ZIndex = 4,
		Parent = iconCircle,
	})

	local title = new("TextLabel", {
		Position = UDim2.new(0, 20, 0, 96),
		Size = UDim2.new(1, -40, 0, 26),
		BackgroundTransparency = 1,
		Text = opts.Title or "Xác thực key",
		Font = FONT_BOLD,
		TextSize = 20,
		TextColor3 = theme.Text,
		ZIndex = 3,
		Parent = card,
	})

	new("TextLabel", {
		Position = UDim2.new(0, 24, 0, 124),
		Size = UDim2.new(1, -48, 0, 36),
		BackgroundTransparency = 1,
		Text = opts.Note or "Nhập key để tiếp tục sử dụng",
		Font = FONT,
		TextSize = 13,
		TextColor3 = theme.SubText,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = 3,
		Parent = card,
	})

	-- Ô nhập key kính mờ
	local inputFrame = new("Frame", {
		Position = UDim2.new(0, 20, 0, 170),
		Size = UDim2.new(1, -40, 0, 44),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = theme.SurfaceT,
		ZIndex = 3,
		Parent = card,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 12 * R), Parent = inputFrame })
	local inputStroke = new("UIStroke", {
		Color = theme.Stroke,
		Transparency = theme.StrokeT,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = inputFrame,
	})

	local input = new("TextBox", {
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Text = "",
		PlaceholderText = "Nhập key...",
		PlaceholderColor3 = theme.SubText,
		Font = FONT_MED,
		TextSize = 14,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 4,
		Parent = inputFrame,
	})

	local status = new("TextLabel", {
		Position = UDim2.new(0, 20, 0, 220),
		Size = UDim2.new(1, -40, 0, 16),
		BackgroundTransparency = 1,
		Text = "",
		Font = FONT,
		TextSize = 12,
		TextColor3 = theme.SubText,
		ZIndex = 3,
		Parent = card,
	})

	local function makeButton(pos, size, text, filled)
		local b = new("TextButton", {
			Position = pos,
			Size = size,
			BackgroundColor3 = filled and theme.Accent or theme.Surface,
			BackgroundTransparency = filled and 0 or theme.SurfaceT,
			Text = "",
			ZIndex = 3,
			Parent = card,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 12 * R), Parent = b })
		if not filled then
			new("UIStroke", {
				Color = theme.Stroke,
				Transparency = theme.StrokeT,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Parent = b,
			})
		end
		new("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = text,
			Font = FONT_BOLD,
			TextSize = 14,
			TextColor3 = filled and C(255, 255, 255) or theme.Text,
			ZIndex = 4,
			Parent = b,
		})
		local base = b.BackgroundTransparency
		b.MouseEnter:Connect(function()
			tween(b, { BackgroundTransparency = math.max(base - 0.12, 0) }, 0.15)
		end)
		b.MouseLeave:Connect(function()
			tween(b, { BackgroundTransparency = base }, 0.15)
		end)
		return b
	end

	local getKey
	local confirm
	if opts.URL then
		getKey = makeButton(UDim2.new(0, 20, 0, 248), UDim2.new(0.5, -26, 0, 44), "Lấy key", false)
		confirm = makeButton(UDim2.new(0.5, 6, 0, 248), UDim2.new(0.5, -26, 0, 44), "Xác nhận", true)
	else
		confirm = makeButton(UDim2.new(0, 20, 0, 248), UDim2.new(1, -40, 0, 44), "Xác nhận", true)
	end

	-- Logic
	local busy, done, result = false, false, nil

	local function setStatus(text, color)
		status.Text = text
		status.TextColor3 = color or theme.SubText
	end

	local function shake()
		local base = card.Position
		for _, off in ipairs({ 10, -10, 6, -6, 0 }) do
			tween(card, { Position = base + UDim2.fromOffset(off, 0) }, 0.05, Enum.EasingStyle.Sine)
			task.wait(0.05)
		end
	end

	local function close()
		tween(dim, { BackgroundTransparency = 1 }, 0.3)
		tween(card, { BackgroundTransparency = 1 }, 0.3)
		tween(cardStroke, { Transparency = 1 }, 0.3)
		tween(cardScale, { Scale = 0.9 }, 0.3)
		task.delay(0.35, function()
			gui:Destroy()
		end)
	end

	local function verify()
		if busy or done then return end
		busy = true
		local key = clean(input.Text)
		if check(key) then
			done, result = true, key
			if saveKey then
				pcall(writefile, keyFile, key)
			end
			setStatus("Xác thực thành công", OK_C)
			close()
		else
			setStatus("Key không đúng, thử lại", ERROR_C)
			task.spawn(shake)
			busy = false
		end
	end

	confirm.MouseButton1Click:Connect(verify)
	input.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			verify()
		end
	end)

	if getKey then
		getKey.MouseButton1Click:Connect(function()
			if type(setclipboard) == "function" then
				pcall(setclipboard, opts.URL)
				setStatus("Đã copy link lấy key", theme.Accent)
			else
				setStatus(opts.URL, theme.Accent)
			end
		end)
	end

	-- Hiệu ứng mở
	tween(dim, { BackgroundTransparency = 0.45 }, 0.35)
	tween(card, { BackgroundTransparency = theme.WindowT }, 0.35)
	tween(cardStroke, { Transparency = theme.StrokeT }, 0.35)
	tween(cardScale, { Scale = 1 }, 0.45, Enum.EasingStyle.Back)

	repeat
		task.wait()
	until done

	return result
end

return Library
