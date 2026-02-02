module Raycast
  class Map
    enum MapFloors
      None
      Floor1
      Floor2
    end

    enum MapWalls
      None
      Wall1
    end

    enum MapThings
      None
      PlayerSpawnNorth
      PlayerSpawnEast
      PlayerSpawnSouth
      PlayerSpawnWest
      Barrel
    end

    class_getter floor_textures : Hash(MapFloors, String) = {
      MapFloors::None   => "",
      MapFloors::Floor1 => "FLOOR_2A",
      MapFloors::Floor2 => "FLOOR_4A",
    }

    class_getter wall_textures : Hash(MapWalls, String) = {
      MapWalls::None  => "",
      MapWalls::Wall1 => "BRICK_3A",
    }
  end
end
