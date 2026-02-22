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
puts `xcopy .\\rsrc\\ .\\bin\\release\\#{architecture}\\ /S /E`
puts `shards build raycast --release --no-debug`
FileUtils.cp("./bin/raycast.exe", "./bin/release/#{architecture}")
