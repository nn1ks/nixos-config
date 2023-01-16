{ config, pkgs, ... }:

{
  imports = [
    ../base/configuration.nix
    ./hardware-configuration.nix
  ];

  # Use zram swap.
  zramSwap = {
    enable = true;
    memoryMax = 2000000000; # 2GB
  };

  networking.hostName = "vps-nixos";

  # Open firewall ports for HTTP, HTTPS, and Matrix federation
  networking.firewall.allowedTCPPorts = [ 80 443 8448 ];
  networking.firewall.allowedUDPPorts = [ 80 443 8448 ];

  users.users.niklas = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  
  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "prohibit-password";
      authorizedKeysFiles = [ "data/t14-nixos.pub" ];
    };

    prometheus = {
      enable = true;
      exporters.node.enable = true;
      scrapeConfigs = [
        {
          job_name = "prometheus";
          static_configs = [
            {
              targets = [ "127.0.0.1:8000" ];
            }
          ];
        }
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "127.0.0.1:8001" ];
            }
          ];
        }
      ];
      alertmanager = {
        enable = true;
        listenAddress = "127.0.0.1";
        configuration = {
          route = {
            receiver = "email";
          };
          receivers = [
            {
              name = "email";
              email_configs = [
                {
                  to = "niklas@n1ks.net";
                  from = builtins.readFile ../secrets/posteo-email-address.txt;
                  smarthost = "posteo.de:587";
                  auth_username = builtins.readFile ../secrets/posteo-email-address.txt;
                  auth_password = builtins.readFile ../secrets/posteo-email-password.txt;
                }
              ];
            }
          ];
        };
      };
    };

    grafana = {
      enable = true;
      settings.server = {
        http_addr = "127.0.0.1";
        http_port = 8100;
        domain = "grafana.n1ks.net";
        root_url = "https://grafana.n1ks.net";
      };
    };

    vaultwarden = {
      enable = true;
      config = {
        ADMIN_TOKEN = builtins.readFile ../secrets/vaultwarden-admin-token.txt;
        SIGNUPS_ALLOWED = false;
        SHOW_PASSWORD_HINT = false;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8200;
        WEBSOCKET_ENABLED = true;
        WEBSOCKET_PORT = 8201;
        DOMAIN = "https://vault.n1ks.net";
      };
    };

    searx = {
      enable = true;
      package = pkgs.searxng;
      runInUwsgi = true;
      settings = {
        general = {
          instance_name = "searx";
          enable_metrics = true;
        };
        server = {
          bind_address = "127.0.0.1";
          port = 8300;
          base_url = "https://searx.n1ks.net";
          secret_key = "TODO";
          image_proxy = false;
          method = "GET";
        };
        search = {
          safe_mode = 0;
          autocomplete = "duckduckgo";
          autocomplete_min = 3;
        };
        ui = {
          infinite_scroll = true;
          query_in_title = true;
        };
        categories_as_tabs = {
          general = {};
          images = {};
          videos = {};
          news = {};
          it = {};
          science = {};
          files = {};
        };
      };
    };

    matrix-conduit = {
      enable = true;
      settings.global = {
        address = "127.0.0.1";
        port = 8400;
        server_name = "n1ks.net";
        allow_registration = true; # TODO: Disable
      };
    };

    caddy = {
      enable = true;
      email = "admin@n1ks.net";
      virtualHosts = {
        "n1ks.net".extraConfig = ''
          header /.well-known/matrix/* Content-Type application/json
          header /.well-known/matrix/* Access-Control-Allow-Origin *
          respond /.well-known/matrix/server `{"m.server": "matrix.n1ks.net"}`
          respond /.well-known/matrix/client `{"m.homeserver":{"base_url":"https://matrix.n1ks.net"}}`
        '';

        "promeutheus.n1ks.net".extraConfig = ''
          reverse_proxy http://127.0.0.1:8000
        '';
        "grafana.n1ks.net".extraConfig = ''
          reverse_proxy http://127.0.0.1:8100
        '';
        "vault.n1ks.net".extraConfig = ''
          reverse_proxy /notifications/hub http://127.0.0.1:8200
          reverse_proxy http://127.0.0.1:8201 {
            header_up X-Real-IP {remote_host}
          }
        '';
        "searx.n1ks.net".extraConfig = ''
          reverse_proxy http://127.0.0.1:8300
        '';
        "matrix.n1ks.net".extraConfig = ''
          reverse_proxy http://127.0.0.1:8400
        '';
        "matrix.n1ks.net:8448".extraConfig = ''
          reverse_proxy /_matrix/ http://127.0.0.1:8400
        '';
      };
    };
  };
}
