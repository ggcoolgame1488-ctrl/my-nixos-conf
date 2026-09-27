{ config, pkgs, ... }:

let
  py = pkgs.python3.withPackages (ps: [ ps.cryptography ps.certifi ]);
in
{
  environment.systemPackages = [ pkgs.telegram-desktop ];

  systemd.user.services.tg-ws-proxy = {
    description = "Telegram WebSocket proxy";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      WorkingDirectory = "%h/tg-ws-proxy";
      ExecStart = "${py}/bin/python -m proxy.tg_ws_proxy --port 1443 --secret b3e4132f00d8649c5589ba4b6dd825e6";
      Restart = "on-failure";
    };
  };
}
