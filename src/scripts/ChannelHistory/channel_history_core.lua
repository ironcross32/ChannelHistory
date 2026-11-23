-- The channel_history table holds all of this package's functions and state.
-- Its name and channel_history.add() are the public API that users' triggers call.
channel_history = channel_history or {}
local ch = channel_history

ch.max_messages = 5000
-- Category names in the order they were first seen.
ch.categories = ch.categories or {}
-- Messages per category: { message = text, time = getEpoch() }.
ch.messages = ch.messages or {}
-- Review position per category. 0 means the category hasn't been reviewed yet.
ch.indices = ch.indices or {}
-- Position in ch.categories. 0 means no category is selected.
ch.selected_category = ch.selected_category or 0
-- Press tracking for the Alt+number keys, used to spot double presses.
ch.modes = ch.modes or {}

-- Settings are saved in the profile folder, so they survive restarts and updates.
ch.settingsFile = getMudletHomeDir() .. "/@PKGNAME@_settings.lua"
if not ch.settings then
    ch.settings = { show_timestamps = true }
    if io.exists(ch.settingsFile) then
        table.load(ch.settingsFile, ch.settings)
    end
end

function channel_history.save_settings()
    table.save(channel_history.settingsFile, channel_history.settings)
end

-- Speaks text: announce() on Windows, TTS on other systems.
function channel_history.say(text)
    if getOS() == "windows" then
        announce(text)
    else
        ttsQueue(text)
    end -- if
end -- func

-- Adds a message to a category, creating the category the first time it's used.
function channel_history.add(category, message)
    local ch = channel_history
    if ch.messages[category] == nil then
        ch.messages[category] = {}
        ch.indices[category] = 0
        table.insert(ch.categories, category)
    end
    local list = ch.messages[category]
    table.insert(list, { message = message, time = getEpoch() })
    if #list > ch.max_messages then
        table.remove(list, 1)
        -- Everything moved up one, so move the review position with it.
        if ch.indices[category] > 1 then
            ch.indices[category] = ch.indices[category] - 1
        end
    end
end -- func
