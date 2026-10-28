#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/net.donnybeelo.Convey.svg
export DESKTOP=/usr/share/applications/net.donnybeelo.Convey.desktop
export STARTUPWMCLASS=net.donnybeelo.Convey # Default to Wayland's wmclass. For X11, GTK_CLASS_FIX will force the wmclass to the Wayland one.
export GTK_CLASS_FIX=1

# Deploy dependencies
# /usr/lib/convey has the client library, the plugins and the WebKit web
# process extension, all of them are loaded at runtime. The glob is needed
# in addition to the directory so the libraries are scanned as libraries,
# which is what enables webkit and libpeas deployment
quick-sharun /usr/bin/convey \
             /usr/lib/convey \
             /usr/lib/convey/* \
             /usr/share/xml/iso-codes

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
