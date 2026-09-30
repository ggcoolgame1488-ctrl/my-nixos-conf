{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
   environment.systemPackages = with pkgs; [
     noctalia
     vim 
     wget
     fish
     eza
     bat
     curl
     unimatrix
     btop
     vesktop
     git
     steam-run
     kitty
     firefox
     starship
     efibootmgr
     micro
     polkit
     alacritty
     ntfs3g   
     exfatprogs 
     gnome-themes-extra
     adwaita-icon-theme
     ayugram-desktop
     qbittorrent
     libsecret
     nautilus
     appimage-run
     fuse2
     capitaine-cursors
     adw-gtk3
     fastfetch
     linux-wallpaperengine
     ffmpeg
     wl-clipboard
     xwayland-satellite
     sing-box
     (python3.withPackages (ps: with ps; [
       pydantic
       aiofiles
       aiohttp
       aiohttp-socks
     ]))
     openssh
     sshpass
     libcap
     nftables
     iproute2
     procps
     glib
     gsettings-desktop-schemas

     # --- Зависимости для Noctalia Screen Toolkit ---
     grim         # Захват экрана
     slurp        # Выделение области мышью
     hyprpicker   # Цветовая пипетка
     bc           # Математика для GIF
     jq           # Обработка JSON для API
     xdg-utils    # Открытие ссылок (xdg-open)
     
     # Запись экрана (выберите/оставьте нужные)
     wl-screenrec # Запись области / микрофона
     gpu-screen-recorder # Полноэкранная запись
     mpv          # Предпросмотр видео
     
     # Утилиты
     swappy       # Редактор аннотаций/скриншотов (Markup)
     imagemagick  # Анализ палитры цветов
     zbar         # Сканирование QR-кодов (zbarimg)
     
     # Распознавание текста (OCR) и перевод
     (tesseract.override {
       enableLanguages = [ "eng" "rus" ]; # Английский + Русский
     })
     translate-shell
   ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only    # запасные иконки для любого шрифта
    noto-fonts-color-emoji    # эмодзи
  ];
}
