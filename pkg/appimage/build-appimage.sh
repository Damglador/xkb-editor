#!/bin/sh
set -eux

ARCH="$(uname -m)"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

APP_NAME=xkb-editor

# Configure the AppImage
export ICON=/usr/share/icons/hicolor/scalable/apps/$APP_NAME.svg
export DESKTOP=/usr/share/applications/$APP_NAME.desktop
export OUTPATH=./dist
export OUTNAME=$APP_NAME-"$ARCH".AppImage

# sharun options
export DEPLOY_SYS_PYTHON=1

sudo pacman -S --needed --noconfirm --asdeps git base-devel wget zsync
sudo pacman -S --needed --noconfirm --asdeps breeze qt6ct kvantum lxqt-qtplugin

PACKAGE_NAME=xkb-editor
if [ ! -d "$PACKAGE_NAME" ]; then
  git clone https://aur.archlinux.org/"$PACKAGE_NAME".git
  cd "$PACKAGE_NAME"
else
  cd "$PACKAGE_NAME"
  git pull
fi
makepkg -Cfsi --noconfirm
cd ..

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh --prefer-nano --add-common

# Download and run quick-sharun
wget "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun

# Bundle the application
./quick-sharun "/usr/bin/${APP_NAME}" \
  /usr/lib/libQt6Core.so*  \
  /usr/lib/libQt6Gui.so*

# My tweaks
for item in /usr/lib/python3.14/*; do
  [ "$(basename "$item")" = "site-packages" ] && continue
  cp -r "$item" ./AppDir/lib/python3.14/
done

site_packages="shiboken6 PySide6 lark pydantic pydantic_core"

for package in $site_packages; do
  cp -r /usr/lib/python3.14/site-packages/"$package" ./AppDir/lib/python3.14/site-packages/
done

# Create the AppImage
./quick-sharun --make-appimage
