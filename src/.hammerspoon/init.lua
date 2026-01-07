hs.allowAppleScript(true)
local HOME = os.getenv("HOME")


----------------------------------
-- Auto reload hammerspoon configs
----------------------------------

function reloadConfig(files)
    doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(HOME .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config loaded")


--------------------------------------------
-- Toggle Ghostty background blur with cmd+o
--------------------------------------------

local ghosttyBlurHotkey = hs.hotkey.new({"cmd"}, "o", function()
    local script_dir = HOME .. "/ghq/github.com/peinan/dotfiles/src/.config/ghostty/"
    local script_name = "ghostty-toggle-blur.sh"
    local script_path = script_dir .. script_name
    print("Executing: " .. script_path)
    local out, status = hs.execute("/bin/zsh " .. script_path)
end)

local appWatcher = hs.application.watcher.new(function(appName, eventType, app)
    if (appName == "Ghostty") then
        if (eventType == hs.application.watcher.activated) then
            ghosttyBlurHotkey:enable()
            hs.alert.show("Ghostty Enabled")
        elseif (eventType == hs.application.watcher.deactivated) then
            ghosttyBlurHotkey:disable()
            hs.alert.show("Ghostty Disabled")
        end
    end
end)
appWatcher:start()


------------------
-- GridTile config
------------------

-- Load the GridTile spoon
hs.loadSpoon("GridTile")

local lastTrapped = 0
local doubleTapThreshold = 0.4
local startKeyCode = 105  -- Key: F13
local gridTileStartKeyWatcher

local function createGridTileWatcher()
    local watcher = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
        if event:getKeyCode() ~= startKeyCode then
            return false
        end

        local now = hs.timer.secondsSinceEpoch()

        if (now - lastTrapped) < doubleTapThreshold then
            spoon.GridTile:start()
            lastTrapped = 0
        else
            lastTrapped = now
        end

        return false
    end)
    watcher:start()
    return watcher
end

gridTileStartKeyWatcher = createGridTileWatcher()

-- Expose restart function globally for GridTile to call
function restartGridTileWatcher()
    gridTileStartKeyWatcher:stop()
    gridTileStartKeyWatcher = createGridTileWatcher()
end


----------------------------------------
-- Print Key and Keycode (for debugging)
----------------------------------------

-- tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
--     print(string.format(
--         "Key: %s | KeyCode: %d",
--         hs.keycodes.map[e:getKeyCode()] or "unknown",
--         e:getKeyCode()
--     ))
--     return false
-- end):start()


