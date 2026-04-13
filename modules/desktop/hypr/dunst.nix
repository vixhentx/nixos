{ ... }:
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        browser = "xdg-open";
        follow = "keyboard";
        width = 920;
        height = "(20,100)";
        origin = "top-center";
        offset = "(0,36)";
        corner_radius = 18;
        frame_width = 2;
        separator_height = 0;
        gap_size = 10;
        padding = 10;
        horizontal_padding = 24;
        text_icon_padding = 0;
        icon_position = "off";
        min_icon_size = 0;
        max_icon_size = 0;
        notification_limit = 1;
        progress_bar = false;
        font = "Sarasa Mono SC 12";
        line_height = 0;
        format = "<span size='x-large'><b>%s</b></span>\\n%b";
        markup = "full";
        alignment = "left";
        vertical_alignment = "center";
        word_wrap = true;
        ellipsize = "middle";
        ignore_newline = false;
        show_age_threshold = 60;
        sort = true;
        stack_duplicates = true;
        hide_duplicate_count = false;
        indicate_hidden = false;
        shrink = false;
        sticky_history = true;
        idle_threshold = 120;
        layer = "overlay";
        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "close_current";
        mouse_right_click = "close_all";
      };

      urgency_low = {
        timeout = 3;
        background = "#1e1e2ee6";
        foreground = "#bac2de";
        frame_color = "#6c7086";
      };

      urgency_normal = {
        timeout = 5;
        background = "#1e1e2ef2";
        foreground = "#cdd6f4";
        frame_color = "#89b4fa";
      };

      urgency_critical = {
        timeout = 0;
        background = "#11111bf7";
        foreground = "#f9e2af";
        frame_color = "#f38ba8";
      };
    };
  };
}