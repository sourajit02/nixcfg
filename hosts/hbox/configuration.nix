{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    # ./hardware-configuration.nix
    ./disks.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "25.11"; # never change this
  users.users.root.initialHashedPassword = "$y$j9T$LgZNfZgC.jlSpJHuYdWJW1$YcJSBxMF.9rWLb5ijXRKyoSJgfc6HWNdMlRkUxl1yND";
  security.sudo.wheelNeedsPassword = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 2;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.settings.auto-optimise-store = true;
  # nix.nixPath = [ "/home/s/config" ];
  networking.hostName = "hbox";
  networking.networkmanager.enable = true;
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  time.timeZone = "Australia/Sydney";
  console.keyMap = "colemak";
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    xkb = {
      layout = "us";
      variant = "colemak";
    };
  };
  # system.copySystemConfiguration = true; # cannot be used with nixos-anywhere
  services.openssh.enable = true;
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    git # order matters, so git is first
    curl
    wget
    helix
    yazi
    nushell
  ];

  zramSwap = {
    enable = true;
  };
  services.swapspace = {
    enable = true;
    settings.max_swapsize = "64g";
  };

  hardware.graphics.enable = true;
  environment.variables.EDITOR = "helix";

  users.mutableUsers = false;
  users.users.s = {
    home = "/home/s";
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$LgZNfZgC.jlSpJHuYdWJW1$YcJSBxMF.9rWLb5ijXRKyoSJgfc6HWNdMlRkUxl1yND";
    shell = pkgs.nushell;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
    ];
    createHome = true;
  };

  boot.initrd.systemd.enable = true;
  preservation = {
    enable = true;
    preserveAt."/persist" = {
      directories = [
        "/etc/secureboot"
        "/var/lib/bluetooth"
        "/var/lib/fprint"
        "/var/lib/fwupd"
        "/var/lib/libvirt"
        "/var/lib/power-profiles-daemon"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/rfkill"
        "/var/lib/systemd/timers"
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
      ];
      files = [
        "/var/lib/usbguard/rules.conf"
        {
          file = "/etc/machine-id";
          inInitrd = true;
          how = "symlink";
          configureParent = true;
        }

        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
        }

      ];

      users.s = {
        commonMountOptions = [
          "x-gvfs-hide"
        ];
        directories = [
          "config"
          "apps"
          "courses"
          "downloads"
          # no media, is mounted on separate drive so won't be wiped anyway
          "photos"
          "projects"
          "sitar"
          "texts"
          "work"
          # no need? .Trash-1000 being created per directory anyway
          # {
          #   directory = ".local/share/Trash";
          #   mountOptions = [ "x-gvfs-trash" ];
          #   how = "symlink";
          # }
          {
            directory = ".ssh";
            mode = "0700";
          }
        ];
        files = [
          {
            file = ".config/nushell/history.sqlite3";
            how = "symlink";
          }

        ];
      };
    };

  };

  # add directories here to set permissions correctly
  systemd.tmpfiles.settings.preservation = {
    "/home/s/.config".d = {
      user = "s";
      group = "users";
    };
    "/home/s/.local".d = {
      user = "s";
      group = "users";
    };
    # "/home/s/.local/share".d = {
    #   user = "s";
    #   group = "users";
    # };
    # "/home/s/.local/state".d = {
    #   user = "s";
    #   group = "users";
    # };
  };

  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      # ""
      "/persistent/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      # ""
      "systemd-machine-id-setup --commit --root /persistent"
    ];
  };
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  stylix.image = pkgs.fetchurl {
    url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
    hash = "sha256-enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
  };

}
