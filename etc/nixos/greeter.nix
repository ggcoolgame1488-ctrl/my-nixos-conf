{ config, pkgs, ... }:
{
  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      session.default = "niri";
      user.default = "ilusha";
    };
  };

  security.polkit = {
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        var allowedUsers = ["ilusha"];
        if (action.id == "org.noctalia.greeter.sync-appearance" &&
            action.lookup("program") == "${config.services.displayManager.noctalia-greeter.package}/bin/noctalia-greeter-apply-appearance" &&
            action.lookup("user") == "root" &&
            subject.local && subject.active &&
            allowedUsers.indexOf(subject.user) >= 0) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
