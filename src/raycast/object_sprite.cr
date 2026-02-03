module Raycast
  class Object
    class Sprite
      enum Sprites
        None
        Barrel
      end

      struct Frame
        enum Frames
          None
          Barrel1
        end

        class_getter frame_textures = {
          Frames::None    => "",
          Frames::Barrel1 => "BARREL_1",
        }

        getter frame : Frames
        getter length : Float32

        def initialize(@frame : Frames, @length : Float32)
        end
      end

      class_getter sprites = {
        Sprites::None   => [Frame.new(Frame::Frames::None, 0.0)],
        Sprites::Barrel => [Frame.new(Frame::Frames::Barrel1, 0.0)],
      }

      getter sprite : Sprites
      getter frame_num : Int32 = 0
      getter frame_time_left : Float32

      def initialize(@sprite : Sprites)
        @frame_time_left = Sprite.sprites[@sprite][@frame_num].length
      end

      def get_texture(map : Map) : Raylib::Texture2D
        return map.loaded_sprite_textures[Frame.frame_textures[Sprite.sprites[@sprite][@frame_num].frame]]
      end
    end
  end
end
