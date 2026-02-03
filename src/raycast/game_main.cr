module Raycast
  class Game
    @render : Render
    @objects : Array(Object)
    @map : Map | Nil = nil

    def initialize
      @render = Render.new
      @objects = [] of Object
    end

    def run
      @map = Map.load("map01")
      map = @map.as(Map)
      map.size_x.times do |x|
        map.size_y.times do |y|
          object = Object.spawn(x, y, map.things[x + y*map.size_x])
          @objects << object.as(Object) if object.is_a?(Object)
        end
      end

      player = Player.spawn(@objects)
      Raylib.disable_cursor

      while !Raylib.close_window?
        player.process_inputs(map, @objects, Raylib.get_frame_time)

        @render.render do
          Render::Software.render(map, @objects, player)
        end
      end
    end

    def deinit
      @map.as(Map).deinit unless @map.is_a?(Nil)
      @render.deinit
    end
  end
end
