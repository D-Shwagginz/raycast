require "./raycast/**"
require "raylib-cr"

# TODO: Write documentation for `Raycast`
module Raycast
  VERSION = "0.1.0"

  class_getter rsrc_dir : String = {% if flag?(:debug) %} "./rsrc/" {% else %} "./" {% end %}
  class_getter images_dir : String = rsrc_dir + "images/"
  class_getter sprites_dir : String = rsrc_dir + "images/sprites/"

  @@game : Game | Nil

  def self.run
    {% unless flag?(:debug) %}
      Raylib.set_trace_log_level(Raylib::TraceLogLevel::Error)
    {% end %}

    @@game = Game.new
    @@game.as(Game).run
    @@game.as(Game).deinit
  end

  def self.throw_exception(exception : Exception)
    @@game.as(Game).deinit if @@game == Game
    raise exception
  end
end

Raycast.run
