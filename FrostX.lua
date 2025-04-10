local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Store initial values for sliders
local initialJumpPower = 50
local initialGravity = workspace.Gravity

-- Create the main window
local Window = Rayfield:CreateWindow({
   Name = "❄️FrostX❄️",
   Icon = 'snowflake',
   LoadingTitle = "FrostX",
   LoadingSubtitle = "by Big_Frosty",
   Theme = "Ocean",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "FrostXhubGUI"
   },
   KeySystem = true,
   KeySettings = {
      Title = "FrostX | key",
      Subtitle = "Key System",
      Note = "Key must be obtained from script maker",
      FileName = "FrostXkey",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/6dKKmwxv"}
   }
})

-- Create the Home tab
local MainTab = Window:CreateTab("🏠 Home", nil)
local MainSection = MainTab:CreateSection("Main")

-- Notification upon execution
Rayfield:Notify({
   Title = "You executed FrostX",
   Content = "FrostX is now present",
   Duration = 5,
   Image = 'snowflake',
   Actions = {
      Ignore = {
         Name = "Okay!",
         Callback = function()
            print("The user tapped Okay!")
         end
      },
   },
})

-- Infinite Jump Toggle Button
MainTab:CreateButton({
   Name = "Infinite Jump Toggle",
   Callback = function()
      _G.infinjump = not _G.infinjump
      if _G.infinJumpStarted == nil then
         _G.infinJumpStarted = true
         game.StarterGui:SetCore("SendNotification", {
            Title="FrostX Hub",
            Text="Infinite Jump Activated!",
            Duration=5,
         })

         local plr = game:GetService('Players').LocalPlayer
         local uis = game:GetService('UserInputService')
         
         uis.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if _G.infinjump and input.KeyCode == Enum.KeyCode.Space then
               local humanoid = plr.Character:FindFirstChildOfClass('Humanoid')
               if humanoid then
                  humanoid:ChangeState('Jumping')
                  wait()
                  humanoid:ChangeState('Seated')
               end
            end
         end)
      end
   end,
})

-- WalkSpeed Slider
local walkSpeedSlider
walkSpeedSlider = MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {0, 600},
   Increment = 1,
   Suffix = "speed",
   CurrentValue = 16,
   Flag = "Slider1",
   Callback = function(Value)
      -- Set WalkSpeed to slider value
      local character = game.Players.LocalPlayer.Character
      if character and character:FindFirstChild("Humanoid") then
         character.Humanoid.WalkSpeed = Value
      end
   end,
})

-- Continuously update the WalkSpeed in real-time
game:GetService("RunService").RenderStepped:Connect(function()
   local character = game.Players.LocalPlayer.Character
   if character and character:FindFirstChild("Humanoid") then
      local humanoid = character.Humanoid
      -- Only update if the value is different
      if humanoid.WalkSpeed ~= walkSpeedSlider.CurrentValue then
         humanoid.WalkSpeed = walkSpeedSlider.CurrentValue
      end
   end
end)

-- JumpPower Slider
local jumpPowerSlider
jumpPowerSlider = MainTab:CreateSlider({
   Name = "JumpPower Slider",
   Range = {1, 350},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = initialJumpPower,
   Flag = "sliderjp",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
   end,
})

-- JumpPower Reset Button
MainTab:CreateButton({
   Name = "Reset JumpPower",
   Callback = function()
      -- Reset JumpPower manually without triggering the callback
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = initialJumpPower
      -- Update the slider value by calling the callback manually
      jumpPowerSlider.Callback(initialJumpPower)
   end,
})

-- Gravity Slider
local gravitySlider
gravitySlider = MainTab:CreateSlider({
   Name = "Gravity Controller",
   Range = {0, 500},
   Increment = 10,
   Suffix = "gravity",
   CurrentValue = initialGravity,
   Flag = "GravitySlider",
   Callback = function(Value)
      workspace.Gravity = Value
   end,
})

-- Gravity Reset Button
MainTab:CreateButton({
   Name = "Reset Gravity",
   Callback = function()
      -- Reset the Gravity manually without triggering the callback
      workspace.Gravity = initialGravity
      -- Update the slider value by calling the callback manually
      gravitySlider.Callback(initialGravity)
   end,
})

-- Teleport to Player Input
MainTab:CreateInput({
   Name = "Teleport to Player",
   PlaceholderText = "Enter player name",
   RemoveTextAfterFocusLost = true,
   Callback = function(playerName)
      local targetPlayer = game.Players:FindFirstChild(playerName)
      if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
         game.Players.LocalPlayer.Character:MoveTo(targetPlayer.Character.HumanoidRootPart.Position)
      else
         Rayfield:Notify({
            Title = "Teleport Failed",
            Content = "Player not found or not loaded!",
            Duration = 4,
         })
      end
   end,
})

-- NoClip Toggle
local noclip = false
local noclipConnection

MainTab:CreateToggle({
   Name = "Toggle NoClip",
   CurrentValue = false,
   Flag = "NoClipToggle",
   Callback = function(Value)
      noclip = Value
      local character = game.Players.LocalPlayer.Character
      if character then
         if noclip then
            -- Start NoClip
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
               for _, v in pairs(character:GetDescendants()) do
                  if v:IsA("BasePart") and v.CanCollide == true then
                     v.CanCollide = false
                  end
               end
            end)
         else
            -- Stop NoClip
            if noclipConnection then
               noclipConnection:Disconnect()
               noclipConnection = nil
            end
            
            -- Restore CanCollide to true for all parts when NoClip is disabled
            for _, v in pairs(character:GetDescendants()) do
               if v:IsA("BasePart") then
                  v.CanCollide = true
               end
            end
         end
      end
   end,
})

-- Flight Toggle Integration
local flying = false
local flightSpeed = 50
local flightConn
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- Function to start flying
local function startFlying()
   local character = player.Character or player.CharacterAdded:Wait()
   local hrp = character:WaitForChild("HumanoidRootPart")

   local bg = Instance.new("BodyGyro")
   bg.P = 9e4
   bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
   bg.CFrame = hrp.CFrame
   bg.Parent = hrp

   local bv = Instance.new("BodyVelocity")
   bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
   bv.Velocity = Vector3.zero
   bv.Parent = hrp

   flightConn = runService.RenderStepped:Connect(function()
      local cam = workspace.CurrentCamera
      local moveVec = Vector3.zero

      if uis:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
      if uis:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
      if uis:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
      if uis:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
      if uis:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + cam.CFrame.UpVector end
      if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec = moveVec - cam.CFrame.UpVector end

      if moveVec.Magnitude > 0 then
         bv.Velocity = moveVec.Unit * flightSpeed
      else
         bv.Velocity = Vector3.zero
      end

      bg.CFrame = cam.CFrame
   end)
end

-- Function to stop flying
local function stopFlying()
   if flightConn then
      flightConn:Disconnect()
   end

   local character = player.Character
   if character then
      local hrp = character:FindFirstChild("HumanoidRootPart")
      if hrp then
         for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
               v:Destroy()
            end
         end
      end
   end
end

-- Flight Mode Toggle
MainTab:CreateToggle({
   Name = "Toggle Flight Mode",
   CurrentValue = false,
   Flag = "FlightToggle",
   Callback = function(Value)
      flying = Value
      if flying then
         startFlying()
      else
         stopFlying()
      end
   end,
})
