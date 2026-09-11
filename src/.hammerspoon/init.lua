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


------------------------------------------------------------------
-- Ghostty control, disabled in favour of Ghostty's own config
------------------------------------------------------------------
--
-- ctrl+enter was bound in both places: `keybind =
-- global:ctrl+enter=toggle_visibility` in src/.config/ghostty/config does the
-- same thing. Two handlers racing for one key is the likely reason the toggle
-- became unreliable while other apps held focus, so Ghostty keeps it — it can
-- act on its own windows without asking the accessibility API to guess.
--
-- cmd+o still works from Raycast: ghostty-toggle-blur.sh carries @raycast
-- headers, so the file-swap toggle has an entry point without this hotkey.
-- (Ghostty cannot change blur at runtime, which is why that script swaps
-- background-control between bg-blur and bg-trans and reloads instead.)
--
-- appWatcher existed only to enable and disable the cmd+o hotkey, so it goes
-- with them. Re-enable by removing this block comment.

--[==[
local ghosttyBlurHotkey = hs.hotkey.new({"cmd"}, "o", function()
    local script_dir = HOME .. "/ghq/github.com/peinan/dotfiles/src/.config/ghostty/"
    local script_name = "ghostty-toggle-blur.sh"
    local script_path = script_dir .. script_name
    print("Executing: " .. script_path)
    local out, status = hs.execute("/bin/zsh " .. script_path)
end)

--------------------------------------------
-- Toggle Ghostty visibility with ctrl+enter
--------------------------------------------

local function focusGhosttyWithRetries(attempts)
    local function attempt(remaining)
        local app = hs.application.get("Ghostty")
        if not app then
            return
        end

        app:unhide()
        app:activate(true)

        local win = app:mainWindow()
        if win then
            win:focus()
        end

        if remaining > 1 then
            hs.timer.doAfter(0.2, function()
                attempt(remaining - 1)
            end)
        end
    end

    attempt(attempts or 3)
end

local function toggleGhostty()
    local app = hs.application.get("Ghostty")

    if app and app:isFrontmost() then
        app:hide()
        return
    end

    hs.application.launchOrFocus("Ghostty")
    focusGhosttyWithRetries(3)
end

hs.hotkey.bind({"ctrl"}, "return", toggleGhostty)
hs.hotkey.bind({"ctrl"}, "padenter", toggleGhostty)

local appWatcher = hs.application.watcher.new(function(appName, eventType, app)
    if (appName == "Ghostty") then
        if (eventType == hs.application.watcher.activated) then
            ghosttyBlurHotkey:enable()
            print("Ghostty focused")
        elseif (eventType == hs.application.watcher.deactivated) then
            ghosttyBlurHotkey:disable()
            print("Ghostty unfocused")
        end
    end
end)
appWatcher:start()
]==]


------------------
-- GridTile config
------------------

-- Load the GridTile spoon
hs.loadSpoon("GridTile")
spoon.GridTile:setLayout("vim2")
spoon.GridTile:setGap(1)
spoon.GridTile:setFont("Kusunoki Mono", 64)

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

