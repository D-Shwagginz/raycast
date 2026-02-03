require "json"

module Raycast
  class Map
    getter name : String
    getter size_x : Int32
    getter size_y : Int32
    getter floors : Array(MapFloors)
    getter ceilings : Array(MapFloors)
    getter walls : Array(MapWalls)
    getter things : Array(MapThings)

    getter loaded_floor_images : Hash(String, Raylib::Image) = Hash(String, Raylib::Image).new
    getter loaded_wall_textures : Hash(String, Raylib::Texture2D) = Hash(String, Raylib::Texture2D).new
    getter loaded_sprite_textures : Hash(String, Raylib::Texture2D) = Hash(String, Raylib::Texture2D).new

    class MapNotFound < Exception
    end

    class MapFrameInvalid < Exception
    end

    class MapWallImageNotFound < Exception
    end

    class MapFloorImageNotFound < Exception
    end

    class MapSpriteFrameImageNotFound < Exception
    end

    def initialize(@name : String, @size_x : Int32, @size_y : Int32, @floors : Array(MapFloors), @ceilings : Array(MapFloors), @walls : Array(MapWalls), @things : Array(MapThings))
    end

    def deinit
      loaded_floor_images.each_value { |image| Raylib.unload_image(image) }
      loaded_wall_textures.each_value { |texture| Raylib.unload_texture(texture) }
    end

    def self.frame_to_indices(map_name : String, frame_enum, frame : JSON::Any, frame_pixels : Raylib::Color*, palette : Raylib::Color*)
      y_offset = frame["y"].as_i
      size_x = frame["w"].as_i
      size_y = frame["h"].as_i

      indices = [] of typeof(frame_enum.new(0))
      (size_x * size_y).times do |i|
        pixel = frame_pixels[y_offset * size_x + i]

        pixel_valid = false
        255.times do |pal|
          if pixel == palette[pal] || pixel == Raylib::BLANK
            indices << frame_enum.new(pal)
            pixel_valid = true
            break
          end
        end
        Raycast.throw_exception(MapFrameInvalid.new("Map #{map_name} has an invalid frame in it's png (pixel not found in map palette)")) unless pixel_valid
      end
      return indices
    end

    def self.load(name : String) : self | Nil
      if !File.exists?(Raycast.rsrc_dir + "maps/" + name + ".png") ||
         !File.exists?(Raycast.rsrc_dir + "maps/" + name + ".json")
        Raycast.throw_exception(MapNotFound.new("Map \"#{name}\" .png or .json not found!"))
      end

      json = File.open(Raycast.rsrc_dir + "maps/" + name + ".json")
      map_json = JSON.parse(json)
      json.close

      map_png = Raylib.load_image(Raycast.rsrc_dir + "maps/" + name + ".png")
      map_pixels = Raylib.load_image_colors(map_png)
      Raylib.unload_image(map_png)
      map_png = nil

      pal_png = Raylib.load_image(Raycast.rsrc_dir + "map.png")
      count = 0
      pal = Raylib.load_image_palette(pal_png, 257, pointerof(count))
      Raylib.unload_image(pal_png)
      pal_png = nil

      map = Map.new(
        name,
        map_json["meta"]["size"]["w"].as_i, map_json["meta"]["size"]["h"].as_i // map_json["meta"]["layers"].size,
        frame_to_indices(name, MapFloors, map_json["frames"]["Floor"]["frame"], map_pixels, pal),
        frame_to_indices(name, MapFloors, map_json["frames"]["Ceiling"]["frame"], map_pixels, pal),
        frame_to_indices(name, MapWalls, map_json["frames"]["Wall"]["frame"], map_pixels, pal),
        frame_to_indices(name, MapThings, map_json["frames"]["Thing"]["frame"], map_pixels, pal)
      )

      Raylib.unload_image_colors(map_pixels)
      Raylib.unload_image_palette(pal)

      map.floors.each do |floor|
        img_name = floor_textures[floor]
        unless map.loaded_floor_images.has_key?(img_name) || img_name == ""
          Raycast.throw_exception(MapFloorImageNotFound.new("Map floor texture '#{Raycast.images_dir + img_name + ".PNG"}' not found")) unless File.exists?(Raycast.images_dir + img_name + ".PNG")
          map.loaded_floor_images[img_name] = Raylib.load_image(Raycast.images_dir + img_name + ".PNG")
        end
      end

      map.ceilings.each do |floor|
        img_name = floor_textures[floor]
        unless map.loaded_floor_images.has_key?(img_name) || img_name == ""
          Raycast.throw_exception(MapFloorImageNotFound.new("Map floor texture '#{Raycast.images_dir + img_name + ".PNG"}' not found")) unless File.exists?(Raycast.images_dir + img_name + ".PNG")
          map.loaded_floor_images[img_name] = Raylib.load_image(Raycast.images_dir + img_name + ".PNG")
        end
      end

      map.walls.each do |wall|
        img_name = wall_textures[wall]
        unless map.loaded_wall_textures.has_key?(img_name) || img_name == ""
          Raycast.throw_exception(MapWallImageNotFound.new("Map wall texture '#{Raycast.images_dir + img_name + ".PNG"}' not found")) unless File.exists?(Raycast.images_dir + img_name + ".PNG")
          map.loaded_wall_textures[img_name] = Raylib.load_texture(Raycast.images_dir + img_name + ".PNG")
        end
      end

      Object::Sprite::Frame.frame_textures.each do |frame, texture|
        unless map.loaded_sprite_textures.has_key?(texture) || texture == ""
          Raycast.throw_exception(MapSpriteFrameImageNotFound.new("Sprite frame texture '#{Raycast.sprites_dir + texture + ".PNG"}' not found")) unless File.exists?(Raycast.sprites_dir + texture + ".PNG")
          map.loaded_sprite_textures[texture] = Raylib.load_texture(Raycast.sprites_dir + texture + ".PNG")
        end
      end

      return map
    end
  end
end
