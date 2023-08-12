{ config, pkgs, pkgs-unstable, ... }:

let
  hostname = "mika";
  tailscale_name = "${hostname}-t";

  prometheus_port = 8000;
  prometheus_node_port = 8001;
  grafana_port = 8100;
  vaultwarden_port = 8200;
  vaultwarden_websocket_port = 8201;
  vaultwarden_domain = "vault.n1ks.net";
  searx_port = 8300;
  searx_domain = "searx.n1ks.net";
  matrix_conduit_port = 8400;
  matrix_conduit_domain = "matrix.n1ks.net";
  mautrix_whatsapp_port = 8600;
  lemmy_port = 8536;
  lemmy_ui_port = 8501;

  ssh_keys = [
    ../../data/ssh-key-aiko.pub
    ../../data/ssh-key-kiyo.pub
    ../../data/ssh-key-yuto.pub
  ];
in {
  imports = [
    ./hardware-configuration.nix
    ../../base/configuration.nix
    ../../modules/services/mautrix-whatsapp.nix
  ];

  system.stateVersion = "22.11";

  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };

  # Use zram swap.
  zramSwap = {
    enable = true;
    memoryMax = 2000000000; # 2GB
  };

  networking.hostName = hostname;

  # Open firewall ports for HTTP (80), HTTPS (443), TURN (3478, 5349, 49152-65535), and Matrix federation (8448)
  networking.firewall.allowedTCPPorts = [ 80 443 3478 5349 8448 ];
  networking.firewall.allowedTCPPortRanges = [ { from = 49152; to = 65535; } ];
  networking.firewall.allowedUDPPorts = [ 80 443 3478 5349 8448 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 49152; to = 65535; } ];

  users.users.root = {
    openssh.authorizedKeys.keyFiles = ssh_keys;
  };

  users.users.niklas = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = ssh_keys;
  };

  age.identityPaths = [ "/home/niklas/.ssh/id_ed25519" ];
  age.secrets = {
    lemmy-admin-password.file = ../../secrets/lemmy-admin-password.age;
    vaultwarden-admin-token.file = ../../secrets/vaultwarden-admin-token.age;
    searx-secret-key.file = ../../secrets/searx-secret-key.age;
    coturn-auth-secret.file = ../../secrets/coturn-auth-secret.age;
    mautrix-whatsapp-as-token.file = ../../secrets/mautrix-whatsapp-as-token.age;
    mautrix-whatsapp-hs-token.file = ../../secrets/mautrix-whatsapp-hs-token.age;
    grafana-smtp-user.file = ../../secrets/grafana-smtp-user.age;
    grafana-smtp-password.file = ../../secrets/grafana-smtp-password.age;
  };

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "prohibit-password";
    };

    tailscale.enable = true;

    prometheus = {
      enable = true;
      port = prometheus_port;
      exporters.node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = prometheus_node_port;
      };
      scrapeConfigs = [
        {
          job_name = "prometheus";
          static_configs = [
            {
              targets = [ "127.0.0.1:${builtins.toString prometheus_port}" ];
            }
          ];
        }
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "127.0.0.1:${builtins.toString prometheus_node_port}" ];
            }
          ];
        }
      ];
    };

    grafana = {
      enable = true;
      settings.server = {
        http_addr = "127.0.0.1";
        http_port = grafana_port;
        root_url = "http://${tailscale_name}/grafana";
      };
      settings.smtp = {
        enabled = true;
        user = "niklas.sauter@posteo.net";
        password = "\"\"\"yq42&mutIO;po\"\"\"";
        from_address = "grafana@n1ks.net";
        host = "posteo.de:587";
      };
    };

    vaultwarden = {
      enable = true;
      config = {
        ADMIN_TOKEN = builtins.readFile config.age.secrets.vaultwarden-admin-token.path;
        SIGNUPS_ALLOWED = false;
        SHOW_PASSWORD_HINT = false;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = vaultwarden_port;
        WEBSOCKET_ENABLED = true;
        WEBSOCKET_PORT = vaultwarden_websocket_port;
        DOMAIN = "https://${vaultwarden_domain}";
      };
    };

    searx = {
      enable = true;
      package = pkgs.searxng;
      settings = {
        general = {
          instance_name = "searx";
          enable_metrics = true;
        };
        server = {
          bind_address = "127.0.0.1";
          port = searx_port;
          base_url = "https://${searx_domain}";
          secret_key = builtins.readFile config.age.secrets.searx-secret-key.path;
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
        };
      };
    };

    matrix-conduit = {
      enable = true;
      settings.global = {
        address = "127.0.0.1";
        port = matrix_conduit_port;
        server_name = "n1ks.net";
        allow_registration = false;
        turn_uris = [ "turn:turn.n1ks.net?transport=udp" "turn:turn.n1ks.net?transport=tcp" ];
        turn_secret = builtins.readFile config.age.secrets.coturn-auth-secret.path;
      };
    };

    coturn = {
      enable = true;
      static-auth-secret = builtins.readFile config.age.secrets.coturn-auth-secret.path;
    };

    mautrix-whatsapp = {
      enable = true;
      settings = {
        homeserver = {
          address = "https://matrix.n1ks.net";
          domain = "n1ks.net";
        };
        appservice = {
          address = "http://127.0.0.1:${builtins.toString mautrix_whatsapp_port}";
          hostname = "127.0.0.1";
          port = mautrix_whatsapp_port;
          as_token = builtins.readFile config.age.secrets.mautrix-whatsapp-as-token.path;
          hs_token = builtins.readFile config.age.secrets.mautrix-whatsapp-hs-token.path;
          database = {
            type = "sqlite3-fk-wal";
            uri = "file:///var/lib/mautrix-whatsapp/sqlite3-database?_txlock=immediate";
          };
          id = "whatsapp";
          bot = {
            username = "whatsappbot";
            displayname = "WhatsApp Bridge Bot";
          };
        };
        bridge = {
          # TODO: Enable encryption (requires conduit version 0.6.0 or later)
          # encryption = {
          #   allow = true;
          #   default = true;
          # };
          permissions = {
            "@niklas:n1ks.net" = "admin";
          };
          history_sync.double_puppet_backfill = true;
          bridge_matrix_leave = false;
          enable_status_broadcast = false;
        };
        logging.writers = [
          { type = "journald"; }
        ];
      };
    };

    lemmy = {
      enable = true;
      settings = {
        hostname = "lemmy.n1ks.net";
        port = lemmy_port;
        setup = {
          admin_username = "admin";
          admin_password = builtins.readFile config.age.secrets.lemmy-admin-password.path;
          site_name = "My Lemmy Instance";
        };
      };
      ui.port = lemmy_ui_port;
      database.createLocally = true;
      caddy.enable = true;
    };

    caddy = {
      enable = true;
      email = "admin@n1ks.net";
      virtualHosts = {
        "n1ks.net".extraConfig = ''
          header /.well-known/matrix/* Content-Type application/json
          header /.well-known/matrix/* Access-Control-Allow-Origin *
          respond /.well-known/matrix/server `{"m.server": "${matrix_conduit_domain}:443"}`
          respond /.well-known/matrix/client `{"m.homeserver":{"base_url":"https://${matrix_conduit_domain}"}}`
        '';

        "${vaultwarden_domain}".extraConfig = ''
          reverse_proxy /notifications/hub http://127.0.0.1:${builtins.toString vaultwarden_websocket_port}
          reverse_proxy http://127.0.0.1:${builtins.toString vaultwarden_port} {
            header_up X-Real-IP {remote_host}
          }
        '';

        "${searx_domain}".extraConfig = ''
          reverse_proxy http://127.0.0.1:${builtins.toString searx_port}
        '';

        "${matrix_conduit_domain}".extraConfig = ''
          reverse_proxy http://127.0.0.1:${builtins.toString matrix_conduit_port}
        '';
        "${matrix_conduit_domain}:8448".extraConfig = ''
          reverse_proxy http://127.0.0.1:${builtins.toString matrix_conduit_port}
        '';

        "http://mika-t".extraConfig = ''
          handle_path /grafana/* {
            reverse_proxy http://127.0.0.1:${builtins.toString grafana_port}
          }
        '';
      };
    };
  };
}
