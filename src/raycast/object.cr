module Raycast
  class Object
    enum Objects
      Player
      PlayerSpawn
      Barrel
    end

    getter type : Objects
    property x : Float32
    property y : Float32
    property dir_x : Float64
    property dir_y : Float64
    property dir_right_x : Float64
    property dir_right_y : Float64
    property sprite : Sprite

    def initialize(@type : Objects, @x : Float32, @y : Float32, @dir_x : Float64, @dir_y : Float64, sprite : Sprite::Sprites)
      @sprite = Sprite.new(sprite)
      @dir_right_x = @dir_x * Math.cos(-1.5708) - @dir_y * Math.sin(-1.5708)
      @dir_right_y = @dir_x * Math.sin(-1.5708) + @dir_y * Math.cos(-1.5708)
    end

    def self.spawn(x : Int32, y : Int32, thing : Map::MapThings) : self | Nil
      case thing
      when Map::MapThings::None
        return nil
      when Map::MapThings::PlayerSpawnNorth
        Render::Software.plane_x = Render::Software::DEFAULT_PLANE_LENGTH

        return Object.new(
          Objects::PlayerSpawn, x.to_f32 + 0.5, y.to_f32 + 0.5, 0.0, 1.0, Sprite::Sprites::None
        )
      when Map::MapThings::PlayerSpawnEast
        Render::Software.plane_y = -Render::Software::DEFAULT_PLANE_LENGTH

        return Object.new(
          Objects::PlayerSpawn, x.to_f32 + 0.5, y.to_f32 + 0.5, 1.0, 0.0, Sprite::Sprites::None
        )
      when Map::MapThings::PlayerSpawnSouth
        Render::Software.plane_x = -Render::Software::DEFAULT_PLANE_LENGTH

        return Object.new(
          Objects::PlayerSpawn, x.to_f32 + 0.5, y.to_f32 + 0.5, 0.0, -1.0, Sprite::Sprites::None
        )
      when Map::MapThings::PlayerSpawnWest
        Render::Software.plane_y = Render::Software::DEFAULT_PLANE_LENGTH

        return Object.new(
          Objects::PlayerSpawn, x.to_f32 + 0.5, y.to_f32 + 0.5, -1.0, 0.0, Sprite::Sprites::None
        )
      when Map::MapThings::Barrel
        return Object.new(
          Objects::Barrel, x.to_f32 + 0.5, y.to_f32 + 0.5, 0.0, 0.0, Sprite::Sprites::Barrel
        )
      end
    end
  end
end
