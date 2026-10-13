local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- LOGIKA AUTOFARM & VARIABEL (FORCE TWEEN + SIDE TP)
-- ==========================================
local TotalStealEggs = 9999999999999999
local TweenSpeed = 950
local SideOffset = 100
local SelectedZoneIndex = 1
local IsRunning = false

local CFrameHome = CFrame.new(256.45, 12.36, 182.83)

local Zones = {
	{Name = "Zone 1", CFrame = CFrame.new(258.88, 17.15, 349.58)},
	{Name = "Zone 2", CFrame = CFrame.new(256.45, 13.29, 495.65)},
	{Name = "Zone 3", CFrame = CFrame.new(256.56, 15.96, 668.03)},
	{Name = "Zone 4", CFrame = CFrame.new(260.73, 19.97, 851.86)},
	{Name = "Zone 5", CFrame = CFrame.new(254.87, 12.30, 873.12)},
	{Name = "Zone 6", CFrame = CFrame.new(256.49, 11.40, 1174.37)},
	{Name = "Zone 7", CFrame = CFrame.new(257.36, 14.30, 2790.29)},
}

local CounterParagraph = nil
local StatusParagraph = nil

-- Fungsi Ambil Egg
local function GrabEggs()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local hrp = char.HumanoidRootPart
	
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and obj.Parent then
			local targetPart = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildOfClass("BasePart")
			local pos = targetPart and targetPart.Position or (obj.Parent:IsA("Model") and obj.Parent:GetPivot().Position)
			
			if pos and (pos - hrp.Position).Magnitude <= 35 then
				obj.HoldDuration = 0
				fireproximityprompt(obj)
			end
		end
		
		if obj:IsA("TouchTransmitter") and obj.Parent then
			if (obj.Parent.Position - hrp.Position).Magnitude <= 35 then
				firetouchinterest(hrp, obj.Parent, 0)
				firetouchinterest(hrp, obj.Parent, 1)
			end
		end
	end
end

-- Fungsi Force Tween
local function ForceTweenTo(targetCFrame)
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local hrp = char.HumanoidRootPart
	
	local distance = (hrp.Position - targetCFrame.Position).Magnitude
	local duration = distance / TweenSpeed
	
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
	tween:Play()
	tween.Completed:Wait()
	
	hrp.CFrame = targetCFrame
end

-- Task Loop Autofarm
task.spawn(function()
	while true do
		if IsRunning then
			local targetZone = Zones[SelectedZoneIndex]
			local char = LocalPlayer.Character
			
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hrp = char.HumanoidRootPart
				
				-- 1. Side TP 100 Studs
				if StatusParagraph then StatusParagraph:SetDescription("Side TP Offset (100 Studs)...") end
				hrp.CFrame = hrp.CFrame * CFrame.new(SideOffset, 0, 0)
				task.wait(0.1)
				
				-- 2. Force Tween ke Zone
				local targetSideCFrame = targetZone.CFrame * CFrame.new(SideOffset, 0, 0)
				if StatusParagraph then StatusParagraph:SetDescription("Force Tweening to " .. targetZone.Name .. "...") end
				ForceTweenTo(targetSideCFrame)
				
				-- 3. Move ke Tengah
				if StatusParagraph then StatusParagraph:SetDescription("Moving to Center Egg...") end
				hrp.CFrame = targetZone.CFrame
				task.wait(0.1)
				
				-- 4. Ambil Egg
				if StatusParagraph then StatusParagraph:SetDescription("Collecting Eggs...") end
				GrabEggs()
				task.wait(0.4)
				GrabEggs()
				
				TotalStealEggs = TotalStealEggs + 1
				if CounterParagraph then CounterParagraph:SetDescription("Total Steal Egg: " .. TotalStealEggs) end
				
				-- 5. TP Home
				if StatusParagraph then StatusParagraph:SetDescription("TP Returning Home...") end
				hrp.CFrame = CFrameHome
				task.wait(1.2)
			end
		else
			if StatusParagraph then StatusParagraph:SetDescription("Idle (Toggle Start Farming)") end
			task.wait(0.5)
		end
	end
end)

-- ==========================================
-- PROXYLIB UI & KEY SYSTEM SETUP
-- ==========================================
FloatButton = {
    Shape = "Circle",
    Color = "Black",
    Size  = 50,
    Icon  = "rbxassetid://94158239411156",
}

local ProxyLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProxyHubDev/ProxyLib/refs/heads/main/Documents/ProxyLibrary"))()
local Lib = ProxyLib.new()

local KS = Lib:CreateKeySystem({
    Title = "Ares Hub - Authentication",
    Theme = "Blue",
})

KS:CreateSocialButton({ Type = "Discord", Link = "https://discord.gg/example", Order = 1 })

KS:CreateButton({
    Description = "Verify",
    Callback    = function()
        if KS:GetText() == "VALID-KEY" then
            KS:Destroy()

            local Window = Lib:CreateWindow({
                Title    = "Ares Hub",
                Subtitle = "Premium",
                Theme    = "Blue",
                Size     = Vector2.new(560, 420),
                ConfigPanel = {
                    Enabled = true,
                    Theme   = true,
                    Fps     = true,
                    Ping    = true,
                    Profile = true,
                },
                TitleConfig = {
                    Gradient = true,
                    Words    = {
                        "Ares",
                        { Text = "Hub", Colors = { Color3.fromRGB(255,215,0), Color3.fromRGB(255,140,0) } },
                    },
                },
            })

            Window:CreateSeparator({ Text = "MAIN FARM" })
            local TabMain = Window:CreateTab({ Title = "Autofarm", Icon = "rbxassetid://6031075931" })
            local TabZone = Window:CreateTab({ Title = "Zone", Icon = "rbxassetid://6031082533" })

            -- ================= TAB MAIN =================
            TabMain:CreateSection({ Text = "Farm Controls" })

            -- Toggle Start/Stop
            TabMain:CreateToggle({
                Title    = "Auto Farm Egg",
                Default  = false,
                Callback = function(v)
                    IsRunning = v
                end,
            })

            TabMain:CreateSection({ Text = "Statistics & Status" })

            CounterParagraph = TabMain:CreateParagraph({
                Title       = "Egg Counter",
                Description = "Total Steal Egg: 0",
            })

            StatusParagraph = TabMain:CreateParagraph({
                Title       = "Current Status",
                Description = "Idle",
            })

            -- ================= TAB ZONE =================
            TabZone:CreateSection({ Text = "Select Target Zone" })

            -- Toggle Zone 1 sampai Zone 7
            for i, zone in ipairs(Zones) do
                TabZone:CreateToggle({
                    Title    = "Target " .. zone.Name,
                    Default  = (i == 1),
                    Callback = function(v)
                        if v then
                            SelectedZoneIndex = i
                        end
                    end,
                })
            end

            Window:Notify({
                Title       = "Ares Hub Loaded!",
                Description = "Welcome to Ares Hub Premium.",
                Duration    = 4,
            })
        else
            KS:Notify({ Title = "Invalid Key!", Duration = 3 })
        end
    end,
})
