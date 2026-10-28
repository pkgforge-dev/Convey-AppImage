#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	enchant               \
	folks                 \
	gcr-4                 \
	gettext               \
	git                   \
	gmime3                \
	gnome-online-accounts \
	gobject-introspection \
	gst-plugins-base      \
	gst-plugins-good      \
	gstreamer             \
	gtk4                  \
	iso-codes             \
	itstool               \
	json-glib             \
	libadwaita            \
	libgee                \
	libgoa                \
	libpeas-2             \
	libsecret             \
	libsoup3              \
	libstemmer            \
	libunwind             \
	libytnef              \
	meson                 \
	ninja                 \
	sqlite                \
	vala                  \
	webkitgtk-6.0         \
	xorg-server-xvfb

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here

echo "Building Convey..."
echo "---------------------------------------------------------------"
git clone https://gitlab.gnome.org/donnybeelo/convey ./convey && (
	cd ./convey

	git fetch --tags origin

	# Upstream still carries the old Geary and GNOME tags, only the
	# plain version tags (e.g. 51.0) are release tags
	TAG=$(git tag --sort=-v:refname | grep -E '^[0-9]+\.[0-9]+' | head -n 1)
	git checkout "$TAG"
	echo "$TAG" > ~/version

	# Make the application look for its resources in the AppImage
	# instead of the prefix it was compiled with
	git apply ../patches/*.patch

	# The release profile is mandatory when packaging, otherwise the
	# development app ID and data directories are used
	meson setup build --prefix=/usr --libdir=lib --buildtype=release -D profile=release
	meson compile -C build
	meson install -C build
)

# if you also have to make nightly releases check for DEVEL_RELEASE = 1
#
# if [ "${DEVEL_RELEASE-}" = 1 ]; then
# 	nightly build steps
# else
# 	regular build steps
# fi

# Note that when building manually, you want to output the version of the
# application to a ~/version file and remove VERSION from make-appimage.sh
