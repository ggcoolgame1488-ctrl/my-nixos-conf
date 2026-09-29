{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    zapret
    ipset
    gawk
  ];

  # 1. Симлинки для структуры папок zapret-installer
  systemd.tmpfiles.rules = [
    "L+ /opt/zapret.installer - - - - /etc/nixos/zapret-installer"
    # Создаем симлинки на бинарники nfqws и tpws из пакета NixOS
    "L+ /opt/zapret.installer/files/nfqws - - - - ${pkgs.zapret}/bin/nfqws"
    "L+ /opt/zapret.installer/files/tpws - - - - ${pkgs.zapret}/bin/tpws"
  ];

  environment.etc."zapret".source = ./zapret-installer/files;

  systemd.services.zapret = {
    description = "Zapret DPI bypass service (Snowy-Fluffy)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    # Передаем путь к бинарникам zapret в PATH
    path = with pkgs; [
      zapret
      iptables
      nftables
      ipset
      gawk
      coreutils
      gnugrep
      iproute2
      procps
      bash
      which
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/opt/zapret.installer/files";
      
      ExecStart = "${pkgs.bash}/bin/bash /opt/zapret.installer/files/service.sh start";
      ExecStop = "${pkgs.bash}/bin/bash /opt/zapret.installer/files/service.sh stop";
    };
  };
}
