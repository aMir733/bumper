#!/bin/bash
# Bump the versions of the local repository ebuilds
# Put the script inside the bumper.d directory
# Example script:
#PACKAGE_NAME="amdgpu-pro-vulkan"
#PACKAGE_DIR="media-libs/${PACKAGE_NAME}"
#LATEST_VERSION="$(curl -s https://repo.radeon.com/amd...
#LATEST_EBUILD="${PACKAGE_NAME}-${LATEST_VERSION}.ebuild"

# Defaults
WORKING_EBUILD="_ebuild.bumper"

# local repository directory
REPOSITORY_DIR="/var/db/repos/local"
cd "${REPOSITORY_DIR}"

_sudo () {
	echo "$@" | xargs -t sudo
}

_die () {
	echo "$@"
	exit 1
}

_message () {
	echo "${PACKAGE_DIR}: $@"
}

isempty () {
	[[ "a${1}" == "a" ]] && return 0
	return 1
}

bumpinit () {
	# Checks
	VARIABLES=(PACKAGE_NAME PACKAGE_DIR LATEST_VERSION LATEST_EBUILD)
	for var in $VARIABLES ; do
		eval "var=\${$var}"
		isempty ${var} && _die "Variable ${var} is empty or not defined"
	done
	[[ ! -d "${PACKAGE_DIR}" ]] && _die "Package ${PACKAGE_DIR} doesn't exist"

	_message "Checking for updates..."
	if docheck ; then
		_message "New version found: ${LATEST_VERSION}"
		dobump
	else
		_message "Already up-to-date!"
	fi
}

docheck () {
	[[ -e "${PACKAGE_DIR}/${LATEST_EBUILD}" ]] && return 1
	return 0
}


dobump () {
	[[ -f "${PACKAGE_DIR}/${WORKING_EBUILD}" ]] || _die "plesse set WORKING_EBUILD or copy your working ebuild to ${PACKAGE_DIR}/$WORKING_EBUILD"
	_sudo cp "${PACKAGE_DIR}/${WORKING_EBUILD}" "${PACKAGE_DIR}/${LATEST_EBUILD}"
}

[[ -d bumper.d ]] && for script in bumper.d/* ; do 
	source $script
	bumpinit
done
