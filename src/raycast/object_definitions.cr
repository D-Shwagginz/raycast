module Raycast
  class Object
    struct ObjDef
      class_getter defs = {
        Object::Objects::Player => ObjDef.new(
          Object::Sprite::Sprites::None,
          Object::Flags::None
        ),
        Object::Objects::PlayerSpawn => ObjDef.new(
          Object::Sprite::Sprites::None,
          Object::Flags::None
        ),
        Object::Objects::Barrel => ObjDef.new(
          Object::Sprite::Sprites::Barrel,
          Object::Flags::NonPassable
        ),
      }

      getter starting_sprite : Object::Sprite::Sprites
      getter flags : Object::Flags

      def initialize(@starting_sprite : Object::Sprite::Sprites,
                     @flags : Object::Flags)
      end
    end
  end
end
