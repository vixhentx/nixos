{
  networking.firewall = {
    allowedTCPPorts = [ 80 211 443 ];
    allowedTCPPortRanges = [
      { from = 7000; to = 7100; }
    ];
  };
  services.nginx = {
    enable = true;
    virtualHosts = {
      # Matrix
      "matrix.vixhentx.tech" = {
        enableACME = true;
        forceSSL = true;
        locations."/_matrix/" = {
          proxyPass = "http://127.0.0.1:3020";
          extraConfig = ''
            client_max_body_size 200M;
          '';
        };

        locations."/.well-known/matrix/client" = {
          return = "200 '{\"m.homeserver\": {\"base_url\": \"https://matrix.vixhentx.tech\"}}'";
          extraConfig = ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
          '';
        };

        locations."/.well-known/matrix/server" = {
          return = "200 '{\"m.server\": \"matrix.vixhentx.tech:443\"}'";
          extraConfig = ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
          '';
        };
      };

      # JZM FRPS
      "server.jzm2018.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:6099";
          extraConfig = ''
            client_max_body_size 0;
            proxy_read_timeout 3600s;
            proxy_set_header Authorization $http_authorization;
            proxy_pass_header Authorization;
            proxy_set_header Destination $http_destination;
            proxy_set_header Expect "";
          '';
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "w1084349470@outlook.com";
  };
  vix.services = {
    matrix = {
      enable = true;
      settings = {
        server = "matrix.vixhentx.tech";
        port = 3020;
      };
    };
    tunnel = {
      enable = true; 
      port = 7000;
      allowPorts = [
        { single = 211; } # 管家婆GRASP 使用
        { start = 6000; end = 6999; } # 通用内部
        { start = 7001; end = 7100; } # 通用公开
      ];
    };
  };
}