module Raycast
  class Render
    module Software
      DEFAULT_PLANE_LENGTH = 0.9
      class_property plane_x : Float64 = 0.0
      class_property plane_y : Float64 = 0.0

      def self.render(map : Map, objects : Array(Object), player : Player)
        (Render.game_height - Render.game_height // 2 + 1).times do |y|
          y += Render.game_height // 2 + 1

          ray_dir_x0 = player.object.dir_x - @@plane_x
          ray_dir_y0 = player.object.dir_y - @@plane_y
          ray_dir_x1 = player.object.dir_x + @@plane_x
          ray_dir_y1 = player.object.dir_y + @@plane_y

          pos = y - Render.game_height // 2

          pos_z = 0.5 * Render.game_height

          row_distance = pos_z / pos

          floor_step_x = row_distance * (ray_dir_x1 - ray_dir_x0) / Render.game_width
          floor_step_y = row_distance * (ray_dir_y1 - ray_dir_y0) / Render.game_width

          floor_x = player.object.x + row_distance * ray_dir_x0
          floor_y = -player.object.y + row_distance * ray_dir_y0

          new_cell = true

          cell_x = 0
          cell_y = 0
          floor_image = map.loaded_floor_images.values[0]
          ceiling_image = map.loaded_floor_images.values[0]

          Render.game_width.times do |x|
            new_cell = (cell_x != floor_x.to_i || cell_y != -floor_y.to_i)

            cell_x = floor_x.to_i
            cell_y = -floor_y.to_i

            if map.floors[cell_x + cell_y*map.size_x]? &&
               Map::MapFloors.new(map.floors[cell_x + cell_y*map.size_x]) != Map::MapFloors::None
              floor_image = map.loaded_floor_images[Map.floor_textures[Map::MapFloors.new(map.floors[cell_x + cell_y*map.size_x])]] if new_cell

              tx = (floor_image.width * (floor_x - cell_x)).to_i & (floor_image.width - 1)
              ty = (floor_image.height * (-floor_y - cell_y)).to_i & (floor_image.height - 1)

              color = Raylib.get_image_color(floor_image, tx, ty)
              Raylib.draw_pixel(x, y, color)
            end

            if map.ceilings[cell_x + cell_y*map.size_x]? &&
               Map::MapFloors.new(map.ceilings[cell_x + cell_y*map.size_x]) != Map::MapFloors::None
              ceiling_image = map.loaded_floor_images[Map.floor_textures[Map::MapFloors.new(map.ceilings[cell_x + cell_y*map.size_x])]] if new_cell

              tx = (ceiling_image.width * (floor_x - cell_x)).to_i & (ceiling_image.width - 1)
              ty = (ceiling_image.height * (-floor_y - cell_y)).to_i & (ceiling_image.height - 1)

              color = Raylib.get_image_color(ceiling_image, tx, ty)
              Raylib.draw_pixel(x, Render.game_height - y, color)
            end

            floor_x += floor_step_x
            floor_y += floor_step_y
          end
        end

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
          draw_end = line_height / 2 + Render.game_height / 2

          texture = map.loaded_wall_textures[Map.wall_textures[Map::MapWalls.new(map.walls[map_x + map_y*map.size_x])]]

          wall_x = 0.0
          if side == 0
            wall_x = player.object.y + perp_wall_dist * ray_dir_y
          else
            wall_x = player.object.x + perp_wall_dist * ray_dir_x
          end
          wall_x -= wall_x.floor

          tex_x = (wall_x * texture.width).to_i
          tex_x = texture.width - tex_x - 1 if side == 0 && ray_dir_x > 0
          tex_x = texture.width - tex_x - 1 if side == 1 && ray_dir_y < 0

          step = 1.0 * texture.height / line_height
          tex_pos = (draw_start - Render.game_height / 2 + line_height / 2) * step
          tex_y = tex_pos.to_i! & (texture.height - 1)

          Raylib.draw_texture_pro(
            texture,
            Raylib::Rectangle.new(x: tex_x, y: tex_y, width: 1, height: texture.height),
            Raylib::Rectangle.new(x: x, y: draw_start, width: 1, height: (draw_end - draw_start)),
            Raylib::Vector2.new, 0.0, Raylib::WHITE)
        end
      end
    end
  end
end
