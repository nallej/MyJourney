#!/usr/bin/env sh

# You need to have GIT installed!
#
# set -eu enables two shell options:
#     -e: exit if a command fails (with some exceptions, such as commands in conditionals).
#      -u: treat using an unset variable as an error and exit.

set -eu
type bat >/dev/null 2>&1

REPO_LOCA='https://github.com/folke/tokyonight.nvim.git'  # Set location of the repo
REPO_NAME='tokyonight.nvim/'				  # Declare the repo name
THEME_DIR='extras/sublime/'				  # Declare the theme sub-directory

BAT_THEMES_DIR="$(command bat --config-dir)/themes"
[ ! -d "$BAT_THEMES_DIR" ] && mkdir -p "$BAT_THEMES_DIR"

cd "$BAT_THEMES_DIR"
# Initial run
if [ ! -d "$REPO_NAME" ]; then
	git clone --no-checkout --depth=1 --filter=blob:none "$REPO_LOCA"
	cd "$REPO_NAME"
	git sparse-checkout set --no-cone '!/*' "$THEME_DIR"
	git checkout
# Update font	
else 
	cd "$REPO_NAME"
	git fetch --filter=blob:none
	updates="$(git rev-list HEAD..@{u} -- "$THEME_DIR")"
	[ -n "$updates" ] && git merge --ff-only --log
fi

# Revalidate bat cache
BAT_THEME_CACHE="$(command bat --cache-dir)/themes.bin"
if [ ! -e "$BAT_THEME_CACHE" ] || [ -n "$(find "$BAT_THEMES_DIR" -name '*.tmTheme' -newer "$BAT_THEME_CACHE")" ]; then
	command bat cache --build
fi
