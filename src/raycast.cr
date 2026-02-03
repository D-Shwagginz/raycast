require "./raycast/**"
require "raylib-cr"

# TODO: Write documentation for `Raycast`
module Raycast
  DEV_BUILD = true
  VERSION   = "0.1.0"

  class_getter rsrc_dir : String = DEV_BUILD ? "./rsrc/" : "./"
  class_getter images_dir : String = rsrc_dir + "images/"
  class_getter sprites_dir : String = rsrc_dir + "images/sprites/"

  @@game : Game | Nil

  def self.run
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
