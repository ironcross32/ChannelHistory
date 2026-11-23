channel_history = channel_history or {}

-- sysUninstall fires for every package and module, so only act on our own.
-- The keys are package items now, so Mudlet removes them itself. The settings
-- file is kept so an update or reinstall remembers the timestamp setting.
function channel_history.onUninstall(_, name)
    if name ~= "@PKGNAME@" then return end
    -- Uninstalling never clears Lua globals, so drop the table ourselves.
    channel_history = nil
end -- func
