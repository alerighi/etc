#!/bin/sh
# Bootstrap script that installs all the required components
# Copyright (c) 2020 Alessandro Righi - MIT License

REPO="https://github.com/alerighi/scripts"
GIT_DIRECTORY="${HOME}/git"
REPO_DIRECTORY="${GIT_DIRECTORY}/$(basename "${REPO}")"
VERSION="1.0.0"
INSTALL_SCRIPT="install.sh"
CONFIG_DIR="${REPO_DIRECTORY}/config"

debug() {
    echo "[D] $@"
}

info() {
    echo "==> $@"
}

info2() {
	echo "  -> $@"
}

warn() {
    echo "[W] $@"
}

die() {
    echo "[E] $@"
	exit 1
}

detect_os() {
	info "Detecting current OS"

	case "$(uname)" in
		Linux)
			OS="Linux"
			if command -v apt > /dev/null; then
				PACKAGE_MANAGER="apt"
				DISTRIBUTION="Debian/Ubuntu"
			fi
			if command -v pacman > /dev/null; then
				PACKAGE_MANAGER="pacman"
				DISTRIBUTION="ArchLinux"
			fi
			if command -v yay > /dev/null; then
				PACKAGE_MANAGER="yay"
				DISTRIBUTION="ArchLinux"
			fi
			;;
		Darwin)
			OS="MacOS"
			DISTRIBUTION="macos"
			PACKAGE_MANAGER="brew"
			;;
		FreeBSD)
			OS="FreeBSD"
			DISTRIBUTION="FreeBSD"
			PACKAGE_MANAGER="pkg"
			;;
		*)
			die "OS not supported"
			;;
	esac

	info2 "OS: ${OS}"
	info2 "DISTRIBUTION: ${DISTRIBUTION}"
	info2 "PACKAGE_MANAGER: ${PACKAGE_MANAGER}"
}

install_package() {
	info "Installing packages: $@"

	case "${PACKAGE_MANAGER}" in
		apt)
			(sudo apt update && sudo apt install -y "$@") || die "Error installing $@"
			;;
		pacman)
			sudo pacman -Syu "$@" || die "Error installing $@"
			;;
		yay)
			sudo yay -Syu "$@" || die "Error installing $@"
			;;
		brew)
			brew install "$@" || die "Error installing $@"
			;;
		pkg)
			sudo pkg install "$@" || die "Error installing $@"
			;;
	esac
}

check_git() {
	info "Checking for git"
	if ! command -v git > /dev/null; then
		info2 "Git missing. Trying to install it."
		install_package "git"
	else
		info2 "Git found"
	fi

	if ! command -v git > /dev/null; then
		die "Cannot find git and cannot install it. Try to install it yourself."
	fi
}

update_repo() {
	if [ -d "${REPO_DIRECTORY}/.git" ]; then
		info "Repo already cloned. Pulling it."
		pushd "${REPO_DIRECTORY}" > /dev/null
		git pull || die "Cannot pull repo."
		popd > /dev/null
	else
		info "Pulling repo ${REPO}"
		git clone "${REPO}" "${REPO_DIRECTORY}" || die "Error cloning repo"
	fi
}

bootstrap() {
	info "Bootstrapping system configuration"
	info2 "VERSION: ${VERSION}"
	info2 "SHELL: ${SHELL}"
	info2 "UID: ${UID}"
	info2 "USER: ${USER}"
	info2 "HOME: ${HOME}"

	if [ "${UID}" -eq 0 ]; then
		warn "User has root privileges. Run at your own risk."
	fi

	if ! command -v sudo > /dev/null; then
		warn "Command sudo not found. This script may not function if you are not root."
	fi

	detect_os
	check_git
	update_repo

	info "Done bootstrapping. Running main script."
	cd "${REPO_DIRECTORY}"

	BOOTSTRAP_DONE=1
	source "./${INSTALL_SCRIPT}"
}

check_shell() {
	info "Checking login shell"

	if [ "${OS}" = "MacOS" ]; then
		LOGIN_SHELL=$(dscl . -read /Users/${USER} UserShell | cut -d' ' -f2)
	else
		LOGIN_SHELL=$(grep ${USER} /etc/passwd | cut -d: -f7)
	fi

	info2 "Login shell is: ${LOGIN_SHELL}"

	case ${LOGIN_SHELL} in
		*zsh)
			info2 "Login shell is already zsh :)"
			;;
		*)
			info2 "Setting login shell to zsh"
			ZSH_PATH=$(command -v zsh)

			if ! [ -f ${ZSH_PATH} ]; then
				warn "Zsh binary not found!"
			else
				info2 "Zsh is ${ZSH_PATH}"
			fi

			chsh -s "${ZSH_PATH}" "${USER}"
		;;
	esac
}

install_config() {
	DEST="${CONFIG_DIR}/$1"

	if [ -n $2 ]; then
		SRC="${HOME}/$2"
	else
		SRC="${HOME}/$1"
	fi

	if [ -L "${DEST}" ]; then
		info2 "${SRC} already exists. Doing nothing."
	else
		info2 "Installing symlink: ${SRC} -> ${DEST}"
		ln -is "${DEST}" "${SRC}"
	fi
}

main() {
	info2 "Running main script"

	install_software vim wget curl zsh

	info "Installing config files"
	install_config "zshrc" ".zshrc"
	install_config "vimrc" ".vimrc"

	check_shell
}

if [ "${BOOTSTRAP_DONE}" = "1" ]; then
	main
else
	bootstrap
fi
