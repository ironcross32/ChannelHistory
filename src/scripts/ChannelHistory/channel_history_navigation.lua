channel_history = channel_history or {}

-- Seconds allowed between two presses of an Alt+number key for a double press.
local double_press_timeout = 0.5

local function relative_time(t)
    if t < 1 then
        return "just now"
    elseif t < 60 then
        return math.floor(t) .. " seconds ago"
    elseif t < 3600 then
        local min = math.floor(t / 60)
        local sec = math.floor(t % 60)
        return min .. " minutes " .. sec .. " seconds ago"
    elseif t < 86400 then -- seconds in a day
        local hr = math.floor(t / 3600)
        local min = math.floor((t % 3600) / 60)
        return hr .. " hours " .. min .. " minutes ago"
    end
    local days = math.floor(t / 86400)
    local hr = math.floor((t % 86400) / 3600)
    local min = math.floor((t % 3600) / 60)
    return days .. " days, " .. hr .. " hours, and " .. min .. " minutes ago"
end

-- Announces a category's name and the review position in it.
local function say_category()
    local ch = channel_history
    local name = ch.categories[ch.selected_category]
    if ch.indices[name] == 0 then ch.indices[name] = 1 end
    ch.say(name .. ": " .. ch.indices[name] .. " of " .. #ch.messages[name])
end

-- Speaks a message, with prefix before it and the time it arrived if timestamps are on.
function channel_history.sayMsg(prefix, m)
    local saythis = prefix .. " " .. m.message
    if channel_history.settings.show_timestamps then
        -- End the message with a full stop so the time is read as a separate sentence.
        if m.message:match("%w$") then
            saythis = saythis .. "."
        end
        saythis = saythis .. " " .. relative_time(getEpoch() - m.time)
    end
    channel_history.say(saythis)
end -- func

-- Alt+1 to Alt+0: reads one of the 10 newest messages in the selected category.
-- A double press copies it to the clipboard.
function channel_history.get(which)
    local ch = channel_history
    local str = ""
    if #ch.categories == 0 then
        ch.say("No categories")
        return
    end
    if ch.selected_category == 0 then
        for i, name in ipairs(ch.categories) do
            if name == "all" then
                ch.selected_category = i
            end
        end
        if ch.selected_category > 0 then
            str = "switching to all."
        else
            str = "switching to " .. ch.categories[1] .. ". Use alt left and right arrows to change."
            ch.selected_category = 1
        end
    end
    local item = tonumber(which)
    local list = ch.messages[ch.categories[ch.selected_category]]
    if #list < item then
        ch.say("no message")
        return
    end

    local now = getEpoch()
    local mode = ch.modes[item]
    if mode == nil or now - mode[1] >= double_press_timeout then
        mode = { now, 1 }
        ch.modes[item] = mode
    else
        mode[1] = now
        mode[2] = math.min(mode[2] + 1, 3)
    end
    local m = list[#list + 1 - item]
    if mode[2] == 1 then
        ch.sayMsg(str, m)
    elseif mode[2] == 2 then
        setClipboardText(m.message)
        ch.say("copied")
    end
end -- func

function channel_history.next_category()
    local ch = channel_history
    if #ch.categories == 0 then
        ch.say("no categories")
        return
    end
    ch.selected_category = ch.selected_category + 1
    if ch.selected_category > #ch.categories then
        ch.selected_category = 1
    end
    say_category()
end -- func

function channel_history.previous_category()
    local ch = channel_history
    if #ch.categories == 0 then
        ch.say("no categories")
        return
    end
    ch.selected_category = ch.selected_category - 1
    if ch.selected_category < 1 then
        ch.selected_category = #ch.categories
    end
    say_category()
end -- func

-- Moves the review position by delta messages (negative is older), stopping at either end.
local function move(delta)
    local ch = channel_history
    if #ch.categories == 0 then
        ch.say("no categories")
        return
    end
    if ch.selected_category == 0 then
        ch.say("No category selected.")
        return
    end
    local name = ch.categories[ch.selected_category]
    local count = #ch.messages[name]
    local index = ch.indices[name]
    if index == 0 then
        index = count
    end
    local str = ""
    index = index + delta
    if index > count then
        index = count
        str = "Bottom: "
    elseif index < 1 then
        index = 1
        str = "Top: "
    end
    ch.indices[name] = index
    ch.sayMsg(str, ch.messages[name][index])
end

function channel_history.next_message(skip)
    move(skip or 1)
end -- func

function channel_history.previous_message(skip)
    move(-(skip or 1))
end -- func

-- Deletes the selected category and all of its messages.
function channel_history.delete_category()
    local ch = channel_history
    if #ch.categories == 0 then
        return ch.say("No categories")
    end
    if ch.selected_category == 0 then
        return ch.say("No category selected")
    end -- if
    local name = ch.categories[ch.selected_category]
    ch.messages[name] = nil
    ch.indices[name] = nil
    table.remove(ch.categories, ch.selected_category)
    if #ch.categories == 0 then
        ch.selected_category = 0
        ch.say("no more categories")
        return
    end
    if ch.selected_category > #ch.categories then
        ch.selected_category = 1
    end
    ch.say(ch.categories[ch.selected_category])
end -- func

function channel_history.toggle_timestamps()
    local settings = channel_history.settings
    settings.show_timestamps = not settings.show_timestamps
    channel_history.save_settings()
    local sts = settings.show_timestamps and "on" or "off"
    channel_history.say("announce timestamps with messages now " .. sts)
end -- func
