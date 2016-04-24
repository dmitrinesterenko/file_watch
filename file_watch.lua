--[[
   License: MIT
   Author: Dmitri Nesterenko
   based on: watchman
--]]
require('ev')
local LOOP = ev.Loop.default

function watch_path(path, callback)
    print('watching the path ' .. path)
    local stat = ev.Stat.new(function(loop, stat, revents)
        local data = stat:getdata()
        print(data)
        callback(data.path, data.attr, data.prev)
    end, path)
    stat:start(LOOP)

    ---- TODO: normalize path
    --path_register.add(path, callback, function()
    --    print(path)
    --    stat:stop(LOOP)
    --end)
end

function watch_contents(path, callback, ignore_missing)
    local function file_hash()
        local f = io.open(path)
        if (f) then
            local contents = f:read('*a')
            f:close()
            return sha2.sha256hex(contents)
        else
            return ''
        end
    end

    local last_hash = file_hash()

    local stat = ev.Stat.new(function(loop, stat, revents)
        local data = stat:getdata()

        if (not ignore_missing or data.attr.nlink > 0) then
            local hash = file_hash()
            if (hash ~= last_hash) then
                last_hash = hash
                callback(data.path, data.attr, data.prev)
            end
        end
    end, path)
    stat:start(LOOP)

    --contents_register.add(path, callback, function()
    --    stat:stop(LOOP)
    --end)
end

file_watch = {
  watch_path = watch_path,
  watch_contents = watch_contents
}


return file_watch
