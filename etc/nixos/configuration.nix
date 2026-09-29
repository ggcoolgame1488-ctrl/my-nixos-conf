 # Edit this configuration file to define what should be installed on

# your system. Help is available in the configuration.nix(5) man page, on

# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).


{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia.nix
      ./greeter.nix
      ./tg-ws-proxy.nix
      ./all_nixpkg.nix
      ./noctalia-processes.nix
      ./zapret.nix
    ];


boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      minegrub-world-sel = {
        enable = true;
        customIcons = [
          {
            inherit (config.system) name;
            lineTop = with config.system.nixos; distroName + " " + codeName + " (" + version + ")";
            lineBottom = "Survival Mode, No Cheats, Version: " + config.system.nixos.release;
            imgName = "nixos";
          }
          {
            name = "UEFI Firmware Settings";
            lineTop = "UEFI Firmware Settings";
            lineBottom = "Hardcore Mode, Version: UEFI";
            imgName = "options"; # Использует иконку настроек/опций
          }
        ];
      };
    };

    efi.canTouchEfiVariables = true;
  };

  # Use latest kernel.

  boot.kernelPackages = pkgs.linuxPackages_latest;


  networking.hostName = "nixos"; # Define your hostname.

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.


  # Configure network proxy if necessary

  # networking.proxy.default = "http://user:password@proxy:port/";

  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # Enable networking

  networking.networkmanager.enable = true;
  networking.firewall.checkReversePath = "loose";

  security.polkit.enable = true;
  programs.dconf.enable = true;
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;


  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };


  # Set your time zone.

  time.timeZone = "Europe/Samara";


  # Select internationalisation properties.

  i18n.defaultLocale = "ru_RU.UTF-8";


  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };


  # Configure keymap in X11

  services.xserver.xkb = {
    layout = "ru";
    variant = "";
  };


  programs.niri.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.

  users.users."ilusha" = {
    isNormalUser = true;
    description = "Ilusha";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [];
  };


  environment.sessionVariables.GSETTINGS_SCHEMA_DIR =
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";


  programs.steam.enable = true;


  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  services.flatpak.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      starship init fish | source
    '';
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Важно для Proton и 32-битных игр!
  };

  # Конфигурация подсветки COLORFUL P15
  hardware.colorfulP15Backlight = {
    enable = true;
    forceType = 6; # Если подсветка не заработает, смените на 2 или 243 (согласно README)
    group = "users";
    enableGui = true;
    enableFnKeys = true;
    enableResumeRestore = true;

  };

  environment.shellAliases = {
    ff = "clear && fastfetch";
  };

  # Порядок запуска сервисов подсветки

  systemd.services.kbdlight-restore.after = [ "systemd-modules-load.service" ];
  systemd.services.kbdlight-keys.after = [ "systemd-modules-load.service" ];


  # Включает службу контроля накопителей udisks2 (обязательно для автомонтирования)
  services.udisks2.enable = true;
  
  # Включает GVfs — подсистему GNOME/Nautilus для работы с файловыми системами и смонтированными дисками
  services.gvfs.enable = true;
  


  system.stateVersion = "26.05";

} 
