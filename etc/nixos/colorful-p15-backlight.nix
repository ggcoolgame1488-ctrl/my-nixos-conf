{ config, lib, pkgs, colorful-p15-driver, colorful-p15, ... }:

let
  cfg = config.hardware.colorfulP15Backlight;

  kbdlight = pkgs.writeShellScriptBin "kbdlight" ''
    ${builtins.readFile "${colorful-p15}/kbdlight"}
  '';

  kbdlightListen = pkgs.writeTextFile {
    name = "kbdlight-listen";
    executable = true;
    destination = "/bin/kbdlight-listen";
    text = ''
      #!${pkgs.python3}/bin/python3
      import os, sys
      os.environ["PATH"] = "${lib.makeBinPath [ kbdlight pkgs.coreutils ]}:" + os.environ.get("PATH", "")
      ${builtins.readFile "${colorful-p15}/kbdlight-listen"}
    '';
  };

  kbdlightGui = pkgs.runCommandLocal "kbdlight-gui" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    cat << 'EOF' > $out/bin/.kbdlight-gui-wrapped
#!${pkgs.python3.withPackages (ps: [ ps.pygobject3 ])}/bin/python
${builtins.readFile "${colorful-p15}/kbdlight-gui.py"}
EOF
    chmod +x $out/bin/.kbdlight-gui-wrapped

    makeWrapper $out/bin/.kbdlight-gui-wrapped $out/bin/kbdlight-gui \
      --prefix GI_TYPELIB_PATH : "${lib.makeSearchPathOutput "lib" "lib/girepository-1.0" [
        pkgs.gtk4
        pkgs.libadwaita
        pkgs.graphene
        pkgs.pango
        pkgs.gdk-pixbuf
        pkgs.harfbuzz
        pkgs.cairo
        pkgs.gobject-introspection
      ]}"
  '';

  kbdlightDesktop = pkgs.writeTextFile {
    name = "kbdlight-desktop";
    destination = "/share/applications/kbdlight.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Keyboard Backlight
      Comment=Control the RGB keyboard backlight
      Exec=${kbdlightGui}/bin/kbdlight-gui
      Icon=input-keyboard
      Terminal=false
      Categories=Settings;HardwareSettings;Utility;
      Keywords=keyboard;backlight;rgb;light;led;
    '';
  };

colorfulP15Driver =
  config.boot.kernelPackages.callPackage
    ({ stdenv
     , kernel
     , kernelModuleMakeFlags
     , kmod
     , pahole
     , udevCheckHook
     , bash
     }:
      stdenv.mkDerivation {
        pname = "tuxedo-drivers-colorful-p15";
        version = "4.18.1+commown1";

        src = colorful-p15-driver;

        patches = [
          "${colorful-p15}/driver/0001-colorful-p15-kbd-backlight.patch"
        ];

        nativeBuildInputs = [
          kmod
          udevCheckHook
        ] ++ kernel.moduleBuildDependencies;

        buildInputs = [ pahole ];

        makeFlags = kernelModuleMakeFlags ++ [
          "KERNELRELEASE=${kernel.modDirVersion}"
          "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
          "INSTALL_MOD_PATH=${placeholder "out"}"
        ];

        dontAddPrefix = true;

        installPhase = ''
          runHook preInstall

          mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra

          find . -name "*.ko" -exec cp {} $out/lib/modules/${kernel.modDirVersion}/extra/ \;

          if [ -d usr/lib/udev/rules.d ]; then
            substituteInPlace usr/lib/udev/rules.d/* \
              --replace-fail "/bin/bash" "${lib.getExe bash}" \
              --replace-fail "/bin/sh" "${lib.getExe bash}" || true

            install -Dm0644 \
              usr/lib/udev/rules.d/* \
              -t "$out/etc/udev/rules.d"
          fi

          runHook postInstall
        '';

        doInstallCheck = false;

        meta = {
          description = "Patched TUXEDO/Clevo drivers for COLORFUL P15 23";
          homepage = "https://github.com/JAmanOG/colorful-p15-keyboard-backlight";
          license = lib.licenses.gpl2Plus;
          platforms = lib.platforms.linux;
        };
      })
    {};
in
{
  options.hardware.colorfulP15Backlight = {
    enable = lib.mkEnableOption
      "COLORFUL P15 23 RGB keyboard backlight";

    forceType = lib.mkOption {
      type = lib.types.enum [ 1 2 6 243 ];
      default = 6;
      description = ''
        Forced Clevo keyboard backlight type:
        1=fixed, 2=3-zone RGB, 6=1-zone RGB, 243=per-key RGB.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "users";
      description = "Group allowed to control the keyboard backlight.";
    };

    enableGui = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    enableFnKeys = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    enableResumeRestore = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    # This replaces hardware.tuxedo-drivers.enable. Do not enable both.
    boot.extraModulePackages = [ colorfulP15Driver ];

    boot.kernelModules = [
      "clevo_acpi"
      "clevo_wmi"
      "tuxedo_keyboard"
    ];

    boot.extraModprobeConfig = ''
      options tuxedo_keyboard force_clevo_kb_backlight_type=${toString cfg.forceType}
    '';

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="leds", KERNEL=="rgb:kbdlight", \
        RUN+="${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/chgrp ${cfg.group} /sys/class/leds/%k/brightness /sys/class/leds/%k/multi_intensity && ${pkgs.coreutils}/bin/chmod 0664 /sys/class/leds/%k/brightness /sys/class/leds/%k/multi_intensity'"
    '';

    environment.systemPackages =
      [ kbdlight kbdlightDesktop ]
      ++ lib.optional cfg.enableGui kbdlightGui
      ++ lib.optional cfg.enableFnKeys kbdlightListen;

    systemd.tmpfiles.rules = [
      "d /var/lib/kbdlight 0775 root ${cfg.group} -"
    ];

    systemd.services.kbdlight-restore = {
      description = "Restore COLORFUL P15 keyboard backlight";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-modules-load.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${kbdlight}/bin/kbdlight restore --wait";
      };
    };

    systemd.services.kbdlight-keys = lib.mkIf cfg.enableFnKeys {
      description = "COLORFUL P15 keyboard backlight Fn-key listener";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-modules-load.service" ];
      serviceConfig = {
        ExecStart = "${kbdlightListen}/bin/kbdlight-listen";
        Restart = "always";
        RestartSec = 2;
      };
    };

    environment.etc."systemd/system-sleep/kbdlight-resume" =
      lib.mkIf cfg.enableResumeRestore {
        mode = "0755";
        text = ''
          #!/bin/sh
          case "$1" in
            post)
              ${kbdlight}/bin/kbdlight restore --wait || true
              ;;
          esac
        '';
      };
  };
}
