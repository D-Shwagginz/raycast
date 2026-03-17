require "file_utils"

architecture = ""
{% if flag?(:arm) || flag?(:aarch64) %}
  architecture = "arm"
{% elsif flag?(:x86_64) %}
  architecture = "x86"
{% end %}

begin
  FileUtils.rm_r("./bin/release/#{architecture}")
rescue File::NotFoundError
end

filename = ""

{% if flag?(:unix) %}
  puts `mkdir -p ./bin/release/#{architecture}`
  puts `cp -r ./rsrc/. ./bin/release/#{architecture}/`
  filename = "raycast"
{% elsif flag?(:windows) %}
  puts `xcopy .\\rsrc\\ .\\bin\\release\\#{architecture}\\ /S /E`
  filename = "raycast.exe"
{% end %}


puts `shards build raycast --release --no-debug`

FileUtils.cp("./bin/#{filename}", "./bin/release/#{architecture}")
