local ProgressBar = {}
local isShowing = false
local currentProgress = 0
local currentLabel = ""
local currentTheme = "default"
local startTime = 0
local endTime = 0
local currentCallback = nil
local progressThread = nil

local Config = Config or {}

function GetAbsoluteCoords(relativeX, relativeY)
    local screenWidth, screenHeight = GetScreenResolution()
    return relativeX * screenWidth, relativeY * screenHeight
end

function DrawRoundedRectangle(x, y, width, height, radius, color)
    local X, Y, W, H = x - width/2, y - height/2, width, height
    
    DrawRect(X + radius, Y + radius, radius, radius, color[1], color[2], color[3], color[4])
    DrawRect(X + W - radius, Y + radius, radius, radius, color[1], color[2], color[3], color[4])
    DrawRect(X + radius, Y + H - radius, radius, radius, color[1], color[2], color[3], color[4])
    DrawRect(X + W - radius, Y + H - radius, radius, radius, color[1], color[2], color[3], color[4])
    
    DrawRect(X + radius, Y, W - radius * 2, H, color[1], color[2], color[3], color[4])
    DrawRect(X, Y + radius, W, H - radius * 2, color[1], color[2], color[3], color[4])
end

function DrawProgressBar(progress, label, theme)
    local themeData = Config.themes[theme] or Config.themes.default
    
    local posX, posY = GetAbsoluteCoords(Config.position.x, Config.position.y)
    local width, height = GetAbsoluteCoords(Config.size.width, Config.size.height)
    
    local progressWidth = (width - 4) * (progress / 100)
    local radius = themeData.borderRadius
    
    DrawRoundedRectangle(posX, posY + 2, width, height, radius, {0, 0, 0, 100})
    DrawRoundedRectangle(posX, posY, width, height, radius, themeData.bgColor)
    
    if progressWidth > radius * 2 then
        local fillColor = themeData.fillColor
        if progress >= 100 and Config.enablePulseEffect then
            local pulse = math.abs(math.sin(GetGameTimer() * 0.01)) * 50
            fillColor = {fillColor[1], fillColor[2], fillColor[3], math.min(255, fillColor[4] + pulse)}
        end
        DrawRoundedRectangle(posX - (width/2 - progressWidth/2), posY, progressWidth, height, radius, fillColor)
    end
    
    DrawRoundedRectangle(posX, posY, width, height, radius, themeData.borderColor)
    
    SetTextFont(4)
    SetTextScale(0.35, 0.35)
    SetTextColour(themeData.textColor[1], themeData.textColor[2], themeData.textColor[3], themeData.textColor[4])
    SetTextEntry("STRING")
    SetTextCentre(true)
    
    local displayText = label
    if Config.showPercentage then
        displayText = displayText .. string.format(" (%.0f%%)", progress)
    end
    
    AddTextComponentString(displayText)
    DrawText(posX / GetScreenResolution(), (posY - 0.012) / GetScreenResolution())
    
    if Config.showCancelText and progress < 100 then
        SetTextFont(4)
        SetTextScale(0.28, 0.28)
        SetTextColour(200, 200, 200, 180)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString("Press ESC to cancel")
        DrawText(posX / GetScreenResolution(), (posY + 0.02) / GetScreenResolution())
    end
end

function ProgressBar.ShowProgressBar(duration, label, theme, callback)
    if isShowing then
        print("[ProgressBar] A progress bar is already showing!")
        return false
    end
    
    isShowing = true
    currentProgress = 0
    currentLabel = label or "Processing..."
    currentTheme = theme or "default"
    startTime = GetGameTimer()
    endTime = startTime + duration
    currentCallback = callback
    
    if Config.enableSounds then
        local themeData = Config.themes[currentTheme] or Config.themes.default
        PlaySoundFrontend(-1, themeData.sound or Config.startSound, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
    
    progressThread = Citizen.CreateThread(function()
        while isShowing do
            local currentTime = GetGameTimer()
            local elapsed = currentTime - startTime
            currentProgress = math.min((elapsed / duration) * 100, 100)
            
            DrawProgressBar(currentProgress, currentLabel, currentTheme)
            
            if currentTime >= endTime then
                ProgressBar.StopProgressBar(true)
                break
            end
            
            local cancelPressed = false
            for _, key in ipairs(Config.cancelKeys) do
                if IsControlJustPressed(0, key) then
                    cancelPressed = true
                    break
                end
            end
            
            if cancelPressed then
                ProgressBar.StopProgressBar(false)
                break
            end
            
            Citizen.Wait(0)
        end
    end)
    
    return true
end

function ProgressBar.StopProgressBar(success)
    if not isShowing then return end
    
    isShowing = false

    if Config.enableSounds then
        if success then
            PlaySoundFrontend(-1, Config.completeSound, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        else
            PlaySoundFrontend(-1, Config.cancelSound, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        end
    end
    
    if currentCallback then
        currentCallback(success)
        currentCallback = nil
    end
    
    currentProgress = 0
    currentLabel = ""
    currentTheme = "default"
end

function ProgressBar.IsProgressBarShowing()
    return isShowing
end

exports('ShowProgressBar', function(duration, label, theme, callback)
    return ProgressBar.ShowProgressBar(duration, label, theme, callback)
end)

exports('StopProgressBar', function()
    ProgressBar.StopProgressBar(false)
end)

exports('IsProgressBarShowing', function()
    return ProgressBar.IsProgressBarShowing()
end)

RegisterCommand('testprogress', function(source, args)
    local duration = tonumber(args[1]) or 5000
    local theme = args[2] or "default"
    local label = "Testing Progress Bar"
    
    if args[3] then
        label = table.concat(args, " ", 3)
    end
    
    print(string.format("^5[ProgressBar] Starting test: %dms, theme: %s, label: %s", duration, theme, label))
    
    local success = exports[GetCurrentResourceName()]:ShowProgressBar(duration, label, theme, function(completed)
        if completed then
            print("^2[ProgressBar] Test completed successfully!")
        else
            print("^1[ProgressBar] Test was cancelled!")
        end
    end)
    
    if not success then
        print("^1[ProgressBar] Could not start progress bar - one is already showing!")
    end
end, false)

RegisterCommand('pb_test', function()
    exports[GetCurrentResourceName()]:ShowProgressBar(3000, "Simple Test", "default", function(success)
        if success then
            print("^2Simple test completed!")
        else
            print("^1Simple test cancelled!")
        end
    end)
end, false)

RegisterCommand('pb_themes', function()
    local themes = {"default", "success", "warning", "error", "purple", "dark"}
    
    local function runNextTheme(index)
        if index > #themes then return end
        
        local theme = themes[index]
        exports[GetCurrentResourceName()]:ShowProgressBar(2000, "Theme: " .. theme, theme, function(success)
            if success then
                Citizen.Wait(300)
                runNextTheme(index + 1)
            end
        end)
    end
    
    runNextTheme(1)
end, false)

print("^2[ProgressBar] Modern Progress Bar loaded successfully!")
print("^5[ProgressBar] Commands: /testprogress [ms] [theme] [label], /pb_test, /pb_themes")
