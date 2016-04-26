--[[
   License: MIT
   Author: Dmitri Nesterenko
   Derived from and based on: github.com/miGlanz/watchman and lfs
--]]
require('ev')
require('lfs')
require('sha2')

local LOOP = ev.Loop.new()

function watch_path(path, callback)
    if(DEBUG) then
      print('watching path' .. path)
    end
    local stat = ev.Stat.new(function(loop, stat, revents)
        local data = stat:getdata()
        print(data)
        callback(data.path, data.attr, data.prev)
    end, path)
    stat:start(LOOP)
end

function watch_contents(path, callback, ignore_missing)
    if(DEBUG) then
      print('watching contents ' .. path)
    end
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
end

function watch_directory (path, callback)
  for file in lfs.dir(path) do
      if file ~= "." and file ~= ".." then
          local f = path..'/'..file
          local attr = lfs.attributes (f)
          assert (type(attr) == "table")
          if attr.mode == "directory" then
            watch_path(f, callback)
            watch_directory (f, callback)
          else
            --TODO the attr['change'] can be used to monitor for file changes
            --more efficiently than calculating a sha2 of all of the content
            --and comparing that
            watch_contents(f, callback, true)
            --for name, value in pairs(attr) do
            --      print (name, value)
            --end
          end
      end
  end
end

function watch_path_and_contents(path, callback)
  watch_path(path, callback)
  watch_directory(path, callback)
end

function start(watch_method, path, callback)
  ev.Idle.new(function(loop, idle, revents)
    watch_method(path, callback)
    idle:stop(LOOP)
  end):start(LOOP)
  LOOP:loop()
end

file_watch = {
  watch_path = watch_path,
  watch_contents = watch_contents,
  watch_path_and_contents = watch_path_and_contents,
  start = start
}


return file_watch
