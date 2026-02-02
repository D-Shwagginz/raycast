module Raycast
  class Render
    module Software
      DEFAULT_PLANE_LENGTH = 0.9
      class_property plane_x : Float64 = 0.0
      class_property plane_y : Float64 = 0.0

      @@horz_weight_precomputed : Array(Float64) = [] of Float64

      def self.precompute
        (Render.game_height + 2).times { |y| @@horz_weight_precomputed << Render.game_height / (2.0 * y - Render.game_height) }
      end

      def self.render(map : Map, objects : Array(Object), player : Player)
        (Render.game_width + 1).times do |x|
          camera_x = 2 * x / Render.game_width.to_f64 - 1
          ray_dir_x = player.object.dir_x + @@plane_x * camera_x
          ray_dir_y = -(player.object.dir_y + @@plane_y * camera_x)

          map_x = player.object.x.to_i
          map_y = player.object.y.to_i

          side_dist_x = 0.0
          side_dist_y = 0.0

          delta_dist_x = (ray_dir_x == 0) ? 1 ^ 30 : (1 / ray_dir_x).abs
          delta_dist_y = (ray_dir_y == 0) ? 1 ^ 30 : (1 / ray_dir_y).abs

          perp_wall_dist = 0.0

          step_x = 0
          step_y = 0

          hit = 0
          side = 0

          if ray_dir_x < 0
            step_x = -1
            side_dist_x = (player.object.x - map_x) * delta_dist_x
          else
            step_x = 1
            side_dist_x = (map_x + 1.0 - player.object.x) * delta_dist_x
          end

          if ray_dir_y < 0
            step_y = -1
            side_dist_y = (player.object.y - map_y) * delta_dist_y
          else
            step_y = 1
            side_dist_y = (map_y + 1.0 - player.object.y) * delta_dist_y
          end

          while hit == 0
            if side_dist_x < side_dist_y
              side_dist_x += delta_dist_x
              map_x += step_x
              side = 0
            else
              side_dist_y += delta_dist_y
              map_y += step_y
              side = 1
            end
            hit = 1 if map.walls[map_x + map_y*map.size_x] != Map::MapWalls::None
          end

          if side == 0
            perp_wall_dist = (side_dist_x - delta_dist_x)
          else
            perp_wall_dist = (side_dist_y - delta_dist_y)
          end

          line_height = (Render.game_height / perp_wall_dist).to_i

          draw_start = -line_height / 2 + Render.game_height / 2
          draw_start = 0 if draw_start < 0
          draw_end = line_height / 2 + Render.game_height / 2
          draw_end = Render.game_height if draw_end >= Render.game_height

          image = map.loaded_wall_images[Map.wall_textures[Map::MapWalls.new(map.walls[map_x + map_y*map.size_x])]]

          wall_x = 0.0
          if side == 0
            wall_x = player.object.y + perp_wall_dist * ray_dir_y
          else
            wall_x = player.object.x + perp_wall_dist * ray_dir_x
          end
          wall_x -= wall_x.floor

          tex_x = (wall_x * image.width).to_i
          tex_x = image.width - tex_x - 1 if side == 0 && ray_dir_x > 0
          tex_x = image.width - tex_x - 1 if side == 1 && ray_dir_y < 0

          step = 1.0 * image.height / line_height
          tex_pos = (draw_start - Render.game_height / 2 + line_height / 2) * step
          (draw_end - draw_start).to_i.times do |y|
            tex_y = tex_pos.to_i! & (image.height - 1)
            tex_pos += step
            color = Raylib.get_image_color(image, tex_x, tex_y)
            if side == 0
              color.r /= 2
              color.g /= 2
              color.b /= 2
            end

            Raylib.draw_pixel(x, y + draw_start, color)
          end

          floor_x_wall = 0.0
          floor_y_wall = 0.0

          if side == 0 && ray_dir_x > 0
            floor_x_wall = map_x
            floor_y_wall = map_y + wall_x
          elsif side == 0 && ray_dir_x < 0
            floor_x_wall = map_x + 1.0
            floor_y_wall = map_y + wall_x
          elsif side == 1 && ray_dir_y > 0
            floor_x_wall = map_x + wall_x
            floor_y_wall = map_y
          else
            floor_x_wall = map_x + wall_x
            floor_y_wall = map_y + 1.0
          end

          draw_end = Render.game_height if draw_end < 0

          (Render.game_height - draw_end + 1).to_i.times do |y|
            y += draw_end + 1
            weight = @@horz_weight_precomputed[y.to_i] / perp_wall_dist

            current_floor_x = weight * floor_x_wall + (1.0 - weight) * player.object.x
            current_floor_y = weight * floor_y_wall + (1.0 - weight) * player.object.y

            unless Map::MapFloors.new(map.floors[current_floor_x.to_i + current_floor_y.to_i*map.size_x]) == Map::MapFloors::None
              floor_image = map.loaded_floor_images[Map.floor_textures[Map::MapFloors.new(map.floors[current_floor_x.to_i + current_floor_y.to_i*map.size_x])]]

              floor_tex_x = (current_floor_x * floor_image.width).to_i % floor_image.width
              floor_tex_y = (current_floor_y * floor_image.height).to_i % floor_image.height

              Raylib.draw_pixel(x, y - 1, Raylib.get_image_color(floor_image, floor_tex_x, floor_tex_y))
            end

            unless Map::MapFloors.new(map.ceilings[current_floor_x.to_i + current_floor_y.to_i*map.size_x]) == Map::MapFloors::None
              ceil_image = map.loaded_floor_images[Map.floor_textures[Map::MapFloors.new(map.ceilings[current_floor_x.to_i + current_floor_y.to_i*map.size_x])]]

              ceil_tex_x = (current_floor_x * ceil_image.width).to_i % ceil_image.width
              ceil_tex_y = (current_floor_y * ceil_image.height).to_i % ceil_image.height

              Raylib.draw_pixel(x, Render.game_height - y, Raylib.get_image_color(ceil_image, ceil_tex_x, ceil_tex_y))
            end
          end
        end
      end
    end
  end
end
