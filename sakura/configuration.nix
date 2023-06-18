{ config, pkgs, pkgs-unstable, mach-lib, ... }:

let
  prometheus_port = 8000;
  prometheus_node_port = 8001;
  grafana_port = 8100;
  grafana_domain = "grafana.n1ks.net";
  vaultwarden_port = 8200;
  vaultwarden_websocket_port = 8201;
  vaultwarden_domain = "vault.n1ks.net";
  searx_port = 8300;
  searx_domain = "searx.n1ks.net";
  matrix_conduit_port = 8400;
  matrix_conduit_domain = "matrix.n1ks.net";
  maubot_port = 8410;
  mautrix_whatsapp_port = 8600;
  lemmy_port = 8536;
  lemmy_ui_port = 8501;

  matrix-conduit = pkgs.callPackage ../modules/packages/matrix-conduit.nix {};

  maubot = mach-lib.buildPythonPackage rec {
    pname = "maubot";
    version = "0.3.1";
    src = pkgs.python39.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-8gJtHwQOR1BqLbWWSFcr3cXDbIvDZwG0MSsoCz/LrnU=";
    };
    patches = [
      # add entry point
      (pkgs.fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/maubot/maubot/pull/146.patch";
        sha256 = "0yn5357z346qzy5v5g124mgiah1xsi9yyfq42zg028c8paiw8s8x";
      })
    ];
    doCheck = false;
    propagatedBuildInputs = [ pkgs.python39.pkgs.setuptools ];
  };
in {
  imports = [
    ./hardware-configuration.nix
    ../base/configuration.nix
    ../modules/services/maubot.nix
    ../modules/services/mautrix-whatsapp.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [ "nodejs-14.21.3" "openssl-1.1.1u" ];

  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };

  # Use zram swap.
  zramSwap = {
    enable = true;
    memoryMax = 2000000000; # 2GB
  };

  networking.hostName = "sakura";

  # Open firewall ports for HTTP (80), HTTPS (443), TURN (3478, 5349, 49152-65535), and Matrix federation (8448)
  networking.firewall.allowedTCPPorts = [ 80 443 3478 5349 8448 ];
  networking.firewall.allowedTCPPortRanges = [ { from = 49152; to = 65535; } ];
  networking.firewall.allowedUDPPorts = [ 80 443 3478 5349 8448 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 49152; to = 65535; } ];

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [ ../data/ssh-key-kita.pub ../data/ssh-key-ryo.pub ];
  };

  users.users.niklas = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = [ ../data/ssh_key_kita.pub ../data/ssh_key_ryo.pub ];
  };

  # Fix lemmy service
  systemd.services.lemmy.environment.LEMMY_DATABASE_URL = pkgs.lib.mkForce "postgres:///lemmy?host=/run/postgresql&user=lemmy";
  nixpkgs.overlays = [(self: super: {
    lemmy-server = pkgs-unstable.lemmy-server.overrideAttrs (old: {
      patches = (old.patches or []) ++ [(super.fetchpatch {
        name = "fix-db-migrations.patch";
        url = "https://gist.githubusercontent.com/matejc/9be474fa581c1a29592877ede461f1f2/raw/83886917153fcba127b43d9a94a49b3d90e635b3/fix-db-migrations.patch";
        hash = "sha256-BvoA4K9v84n60lG96j1+91e8/ERn9WlVTGk4Z6Fj4iA=";
      })];
    });
  })];

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "prohibit-password";
    };

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
        domain = "${grafana_domain}";
        root_url = "https://${grafana_domain}";
      };
    };

    vaultwarden = {
      enable = true;
      config = {
        ADMIN_TOKEN = builtins.readFile ../secrets/vaultwarden-admin-token.txt;
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
          secret_key = builtins.readFile ../secrets/searx-secret-key.txt;
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
      package = matrix-conduit;
      settings.global = {
        address = "127.0.0.1";
        port = matrix_conduit_port;
        server_name = "n1ks.net";
        allow_registration = false;
        turn_uris = [ "turn:turn.n1ks.net?transport=udp" "turn:turn.n1ks.net?transport=tcp" ];
        turn_secret = builtins.readFile ../secrets/coturn-auth-secret.txt;
      };
    };

    coturn = {
      enable = true;
      static-auth-secret = builtins.readFile ../secrets/coturn-auth-secret.txt;
    };

    maubot = {
      enable = true;
      package = maubot;
      settings = {
        server = {
          hostname = "127.0.0.1";
          port = maubot_port;
          public_url = "https://matrix.n1ks.net";
          unshared_secret = builtins.readFile ../secrets/maubot-unshared-secret.txt;
        };
        admins.niklas = "$2b$12$OwYR5D565gLwDpeLVg6azOajf3.JS28rvb7WTL/baKDksVJkT/nxq";
        homeservers = {
          "n1ks.net".url = "https://${matrix_conduit_domain}";
        };
      };
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
          as_token = builtins.readFile ../secrets/mautrix-whatsapp-as-token.txt;
          hs_token = builtins.readFile ../secrets/mautrix-whatsapp-hs-token.txt;
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
        federation.enabled = true;
        setup = {
          admin_username = "admin";
          admin_password = builtins.readFile ../secrets/lemmy-admin-password.txt;
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

        "${grafana_domain}".extraConfig = ''
          reverse_proxy http://127.0.0.1:${builtins.toString grafana_port}
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
          reverse_proxy /_matrix/maubot* http://127.0.0.1:${builtins.toString maubot_port}
          reverse_proxy http://127.0.0.1:${builtins.toString matrix_conduit_port}
        '';
        "${matrix_conduit_domain}:8448".extraConfig = ''
          reverse_proxy http://127.0.0.1:${builtins.toString matrix_conduit_port}
        '';
      };
    };
  };
}
