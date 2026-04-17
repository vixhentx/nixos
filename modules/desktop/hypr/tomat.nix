{ ... }:
{
  services.tomat = {
    enable = true;
    settings = {
      timer = {
        work = 25;
        break = 5;
      };
      display = {
        text_format = "{icon} {time}";
        icons = {
          work = "󱎫";
          break = "󰅶";
          long_break = "󰘀";
          pause = "󰏤";
        };
      };
    };
  };
}