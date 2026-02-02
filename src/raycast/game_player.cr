module Raycast
  class Player
    class PlayerSpawnNotFound < Exception
    end

    COLLISION_DIST = 0.2

    getter object : Object

    def initialize(@object : Object)
    end

    def self.spawn(objects : Array(Object)) : self
      player_spawn = objects.find { |object| object.type == Object::Objects::PlayerSpawn }
      if player_spawn == nil
        Raycast.throw_exception(Player::PlayerSpawnNotFound.new("Player spawn not found"))
      end
      player_spawn = player_spawn.as(Object)
      player_obj = Object.new(Object::Objects::Player, player_spawn.x, player_spawn.y, player_spawn.dir_x, player_spawn.dir_y)
      return Player.new(player_obj)
    end

    def process_inputs(map : Map, delta_time : Float32)
      move_speed = delta_time * 3.0

      if Raylib.key_down?(Raylib::KeyboardKey::W)
        top_left = map.walls[(object.x + object.dir_x * move_speed - COLLISION_DIST).to_i + map.size_x*(object.y - COLLISION_DIST).to_i]
        top_right = map.walls[(object.x + object.dir_x * move_speed + COLLISION_DIST).to_i + map.size_x*(object.y - COLLISION_DIST).to_i]
        bottom_left = map.walls[(object.x + object.dir_x * move_speed - COLLISION_DIST).to_i + map.size_x*(object.y + COLLISION_DIST).to_i]
        bottom_right = map.walls[(object.x + object.dir_x * move_speed + COLLISION_DIST).to_i + map.size_x*(object.y + COLLISION_DIST).to_i]

        object.x += object.dir_x * move_speed if (top_left | top_right | bottom_left | bottom_right) == Map::MapWalls::None

        top_left = map.walls[(object.x - COLLISION_DIST).to_i + map.size_x*(object.y - object.dir_y * move_speed - COLLISION_DIST).to_i]
        top_right = map.walls[(object.x + COLLISION_DIST).to_i + map.size_x*(object.y - object.dir_y * move_speed - COLLISION_DIST).to_i]
        bottom_left = map.walls[(object.x - COLLISION_DIST).to_i + map.size_x*(object.y - object.dir_y * move_speed + COLLISION_DIST).to_i]
        bottom_right = map.walls[(object.x + COLLISION_DIST).to_i + map.size_x*(object.y - object.dir_y * move_speed + COLLISION_DIST).to_i]

        object.y -= object.dir_y * move_speed if (top_left | top_right | bottom_left | bottom_right) == Map::MapWalls::None
      end
      if Raylib.key_down?(Raylib::KeyboardKey::S)
        top_left = map.walls[(object.x - object.dir_x * move_speed - COLLISION_DIST).to_i + map.size_x*(object.y - COLLISION_DIST).to_i]
        top_right = map.walls[(object.x - object.dir_x * move_speed + COLLISION_DIST).to_i + map.size_x*(object.y - COLLISION_DIST).to_i]
        bottom_left = map.walls[(object.x - object.dir_x * move_speed - COLLISION_DIST).to_i + map.size_x*(object.y + COLLISION_DIST).to_i]
        bottom_right = map.walls[(object.x - object.dir_x * move_speed + COLLISION_DIST).to_i + map.size_x*(object.y + COLLISION_DIST).to_i]

        object.x -= object.dir_x * move_speed if (top_left | top_right | bottom_left | bottom_right) == Map::MapWalls::None

        top_left = map.walls[(object.x - COLLISION_DIST).to_i + map.size_x*(object.y + object.dir_y * move_speed - COLLISION_DIST).to_i]
        top_right = map.walls[(object.x + COLLISION_DIST).to_i + map.size_x*(object.y + object.dir_y * move_speed - COLLISION_DIST).to_i]
        bottom_left = map.walls[(object.x - COLLISION_DIST).to_i + map.size_x*(object.y + object.dir_y * move_speed + COLLISION_DIST).to_i]
        bottom_right = map.walls[(object.x + COLLISION_DIST).to_i + map.size_x*(object.y + object.dir_y * move_speed + COLLISION_DIST).to_i]

        object.y += object.dir_y * move_speed if (top_left | top_right | bottom_left | bottom_right) == Map::MapWalls::None
      end

      if Raylib.key_down?(Raylib::KeyboardKey::D)
        top_left = map.walls[(object.x + object.dir_right_x * move_speed - COLLISION_DIST).to_i + map.size_x*(object.y - COLLISION_DIST).to_i]
        top_right = map.walls[(object.x + object.dir_right_x * move_speed + COLLISION_DIST).to_i + map.size_x*(object.y - COLLISION_DIST).to_i]
        bottom_left = map.walls[(object.x + object.dir_right_x * move_speed - COLLISION_DIST).to_i + map.size_x*(object.y + COLLISION_DIST).to_i]
        bottom_right = map.walls[(object.x + object.dir_right_x * move_speed + COLLISION_DIST).to_i + map.size_x*(object.y + COLLISION_DIST).to_i]

        object.x += object.dir_right_x * move_speed if (top_left | top_right | bottom_left | bottom_right) == Map::MapWalls::None

        top_left = map.walls[(object.x - COLLISION_DIST).to_i + map.size_x*(object.y - object.dir_right_y * move_speed - COLLISION_DIST).to_i]
        top_right = map.walls[(object.x + COLLISION_DIST).to_i + map.size_x*(object.y - object.dir_right_y * move_speed - COLLISION_DIST).to_i]
        bottom_left = map.walls[(object.x - COLLISION_DIST).to_i + map.size_x*(object.y - object.dir_right_y * move_speed + COLLISION_DIST).to_i]
        bottom_right = map.walls[(object.x + COLLISION_DIST).to_i + map.size_x*(object.y - object.dir_right_y * move_speed + COLLISION_DIST).to_i]

        object.y -= object.dir_right_y * move_speed if (top_left | top_right | bottom_left | bottom_right) == Map::MapWalls::None
      end
      if Raylib.key_down?(Raylib::KeyboardKey::A)
        top_left = map.walls[(object.x - object.dir_right_x * move_speed - COLLISION_DIST).to_i + map.size_x*(object.y - COLLISION_DIST).to_i]
        top_right = map.walls[(object.x - object.dir_right_x * move_speed + COLLISION_DIST).to_i + map.size_x*(object.y - COLLISION_DIST).to_i]
        bottom_left = map.walls[(object.x - object.dir_right_x * move_speed - COLLISION_DIST).to_i + map.size_x*(object.y + COLLISION_DIST).to_i]
        bottom_right = map.walls[(object.x - object.dir_right_x * move_speed + COLLISION_DIST).to_i + map.size_x*(object.y + COLLISION_DIST).to_i]

        object.x -= object.dir_right_x * move_speed if (top_left | top_right | bottom_left | bottom_right) == Map::MapWalls::None

        top_left = map.walls[(object.x - COLLISION_DIST).to_i + map.size_x*(object.y + object.dir_right_y * move_speed - COLLISION_DIST).to_i]
        top_right = map.walls[(object.x + COLLISION_DIST).to_i + map.size_x*(object.y + object.dir_right_y * move_speed - COLLISION_DIST).to_i]
        bottom_left = map.walls[(object.x - COLLISION_DIST).to_i + map.size_x*(object.y + object.dir_right_y * move_speed + COLLISION_DIST).to_i]
        bottom_right = map.walls[(object.x + COLLISION_DIST).to_i + map.size_x*(object.y + object.dir_right_y * move_speed + COLLISION_DIST).to_i]

        object.y += object.dir_right_y * move_speed if (top_left | top_right | bottom_left | bottom_right) == Map::MapWalls::None
      end

      if Raylib.get_mouse_delta.x != 0
        rot_speed = delta_time * 8.0 * -Raylib.get_mouse_delta.x / 512
        old_dir_x = object.dir_x
        object.dir_x = object.dir_x * Math.cos(rot_speed) - object.dir_y * Math.sin(rot_speed)
        object.dir_y = old_dir_x * Math.sin(rot_speed) + object.dir_y * Math.cos(rot_speed)

        old_dir_right_x = object.dir_right_x
        object.dir_right_x = object.dir_right_x * Math.cos(rot_speed) - object.dir_right_y * Math.sin(rot_speed)
        object.dir_right_y = old_dir_right_x * Math.sin(rot_speed) + object.dir_right_y * Math.cos(rot_speed)

        old_plane_x = Render::Software.plane_x
        Render::Software.plane_x = Render::Software.plane_x * Math.cos(rot_speed) - Render::Software.plane_y * Math.sin(rot_speed)
        Render::Software.plane_y = old_plane_x * Math.sin(rot_speed) + Render::Software.plane_y * Math.cos(rot_speed)
      end
    end
  end
end
