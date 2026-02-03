require "file_utils"

FileUtils.rm_r("./bin/release")
puts `xcopy .\\rsrc\\ .\\bin\\release\\ /S /E`
puts `shards build raycast --release --no-debug`
FileUtils.cp("./bin/raycast.exe", "./bin/release")
