module Raycast
  class Render
    class_getter screen_width : Int32 = 1024
    class_getter screen_height : Int32 = 768

    class_getter game_width : Int32 = 400
    class_getter game_height : Int32 = 225

    @rendertarget : Raylib::RenderTexture2D

    def initialize
      Raylib.set_config_flags(Raylib::ConfigFlags::WindowResizable | Raylib::ConfigFlags::VSyncHint)
      Raylib.init_window(@@screen_width, @@screen_height, "Raycast")
      Raylib.set_window_min_size(@@game_width, @@game_height)

      @rendertarget = Raylib.load_render_texture(@@game_width, @@game_height)
      Raylib.set_texture_filter(@rendertarget.texture, Raylib::TextureFilter::Point)
      Raylib.set_target_fps(60)
    end

    def render(&block)
      w = Raylib.get_screen_width.to_f32 / @@game_width
      h = Raylib.get_screen_height.to_f32 / @@game_height
      scale = w < h ? w : h

      Raylib.set_mouse_offset(-(Raylib.get_screen_width - (@@game_width*scale))*0.5, -(Raylib.get_screen_height - (@@game_height*scale))*0.5)
      Raylib.set_mouse_scale(1/scale, 1/scale)

      Raylib.begin_texture_mode(@rendertarget)
      Raylib.clear_background(Raylib::RED)
      yield
      Raylib.end_texture_mode

      Raylib.begin_drawing
      Raylib.clear_background(Raylib::BLACK)
      Raylib.draw_texture_pro(@rendertarget.texture, Raylib::Rectangle.new(width: @rendertarget.texture.width, height: -@rendertarget.texture.height),
        Raylib::Rectangle.new(x: (Raylib.get_screen_width - (@@game_width*scale))*0.5, y: (Raylib.get_screen_height - (@@game_height*scale))*0.5,
          width: @@game_width*scale, height: @@game_height*scale), Raylib::Vector2.new, 0.0, Raylib::WHITE)
      Raylib.end_drawing
    end

    def deinit
      Raylib.unload_render_texture(@rendertarget)
      Raylib.close_window
    end
  end
end
