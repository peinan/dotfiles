local HOME = os.getenv("HOME")

-- Auto reload hammerspoon configs
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

-- Toggle Ghostty background blur with cmd+o
local ghosttyBlurHotkey = hs.hotkey.new({"cmd"}, "o", function()
    -- hs.alert.show("cmd+o pressed")
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

