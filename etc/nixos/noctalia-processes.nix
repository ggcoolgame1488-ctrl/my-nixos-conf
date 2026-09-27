{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    gtk3
    gobject-introspection
    adwaita-icon-theme
    hicolor-icon-theme

    (let
      myPython = python3.withPackages (ps: with ps; [
        pygobject3
        psutil
        pillow
      ]);
    in
      runCommand "python3-gtk-env" {
        nativeBuildInputs = [ makeWrapper ];
      } ''
        mkdir -p $out/bin

        makeWrapper ${myPython}/bin/python3 $out/bin/python3 \
          --prefix GI_TYPELIB_PATH : "${lib.makeSearchPath "lib/girepository-1.0" [
            gtk3
            gobject-introspection
            pango.out
            pango.dev
            gdk-pixbuf
            atk
            harfbuzz.out
            harfbuzz.dev
            glib.dev
          ]}" \
          --prefix XDG_DATA_DIRS : "${lib.makeSearchPath "share" [
            gtk3
            adwaita-icon-theme
            hicolor-icon-theme
            dejavu_fonts
          ]}"
      '')
  ];
}
