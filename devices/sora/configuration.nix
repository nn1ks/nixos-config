{ config, pkgs, pkgs-unstable, ... }:

let
  hostname = "sora";
  tailscale_name = "${hostname}-t";

  flame_port = 5005;
  prometheus_port = 8000;
  prometheus_node_port = 8001;
  transmission_port = 9091;
  prowlarr_port = 9696;
  sonarr_port = 8989;
  radarr_port = 7878;
  jellyfin_port = 8096;

  ssh_keys = [
    ../../data/ssh-key-aiko.pub
    ../../data/ssh-key-kiyo.pub
    ../../data/ssh-key-yuto.pub
  ];
in {
  imports = [
    ./hardware-configuration.nix
    ../../base/configuration.nix
  ];

  system.stateVersion = "23.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.opengl = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  # Use zram swap.
  zramSwap = {
    enable = true;
    memoryMax = 32000000000; # 32GB
  };

  networking.hostName = hostname;

  # Open firewall ports for HTTP (80), HTTPS (443), Transmission
  networking.firewall.allowedTCPPorts = [ 80 443 transmission_port ];
  networking.firewall.allowedUDPPorts = [ 80 443 transmission_port ];

  users.users.root = {
    openssh.authorizedKeys.keyFiles = ssh_keys;
  };

  users.users.niklas = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = ssh_keys;
  };

  virtualisation.oci-containers.containers.transmission-openvpn = {
    image = "haugene/transmission-openvpn:4.3.2";
    ports = [ "${builtins.toString transmission_port}:${builtins.toString transmission_port}" ];
    volumes = [
      "/mnt/torrents:/data"
      "/var/lib/transmission-openvpn/config:/config"
    ];
    environment = {
      OPENVPN_PROVIDER = "MULLVAD";
      OPENVPN_CONFIG = "ch_all";
      OPENVPN_USERNAME = "6391533451543491";
      OPENVPN_PASSWORD = "6391533451543491";
      LOCAL_NETWORK = "192.168.178.0/24";
      CREATE_TUN_DEVICE = "false";
    };
    extraOptions = [ "--cap-add=NET_ADMIN" "--device=/dev/net/tun:/dev/net/tun" ];
  };

  virtualisation.oci-containers.containers.flame = {
    image = "pawelmalak/flame";
    ports = [ "${builtins.toString flame_port}:${builtins.toString flame_port}" ];
    volumes = [ "/var/lib/flame:/app/data" ];
  };

  environment.systemPackages = with pkgs; [ borgbackup ];

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

    prowlarr.enable = true;

    sonarr.enable = true;

    radarr.enable = true;

    jellyfin.enable = true;

    caddy = {
      enable = true;
      email = "admin@n1ks.net";
      virtualHosts = {
        "http://${tailscale_name}".extraConfig = ''
          handle /* {
            reverse_proxy http://127.0.0.1:${builtins.toString flame_port}
          }

          redir /prowlarr /prowlarr/
          handle /prowlarr/* {
            reverse_proxy http://127.0.0.1:${builtins.toString prowlarr_port}
          }

          redir /sonarr /sonarr/
          handle /sonarr/* {
            reverse_proxy http://127.0.0.1:${builtins.toString sonarr_port}
          }

          redir /radarr /radarr/
          handle /radarr/* {
            reverse_proxy http://127.0.0.1:${builtins.toString radarr_port}
          }

          redir /jellyfin /jellyfin/
          handle /jellyfin/* {
            reverse_proxy http://127.0.0.1:${builtins.toString jellyfin_port}
          }
        '';

        "http://${hostname}".extraConfig = ''
          handle /* {
            reverse_proxy http://127.0.0.1:${builtins.toString flame_port}
          }

          redir /prowlarr /prowlarr/
          handle /prowlarr/* {
            reverse_proxy http://127.0.0.1:${builtins.toString prowlarr_port}
          }

          redir /sonarr /sonarr/
          handle /sonarr/* {
            reverse_proxy http://127.0.0.1:${builtins.toString sonarr_port}
          }

          redir /radarr /radarr/
          handle /radarr/* {
            reverse_proxy http://127.0.0.1:${builtins.toString radarr_port}
          }

          redir /jellyfin /jellyfin/
          handle /jellyfin/* {
            reverse_proxy http://127.0.0.1:${builtins.toString jellyfin_port}
          }
        '';
      };
    };
  };
}
