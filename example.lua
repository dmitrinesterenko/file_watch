fw = require('file_watch')

function callback(path, attributes, previous)
  print(path .. ' changed ' .. attributes)
end

fw.watch_path('.', callback)
