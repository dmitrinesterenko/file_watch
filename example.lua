fw = require('file_watch')

function callback(path, attributes, previous)
  print(path .. ' changed ')
end

file_watch.start(file_watch.watch_path_and_contents, '.', callback)
