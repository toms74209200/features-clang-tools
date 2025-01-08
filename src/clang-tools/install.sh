#!/bin/bash

set -e

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release
# Get an adjusted ID independent of distro variants
MAJOR_VERSION_ID=$(echo ${VERSION_ID} | cut -d . -f 1)
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    ADJUSTED_ID="debian"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

PACKAGES=(curl gnupg)
declare -A INSTALLED

for pkg in "${PACKAGES[@]}"; do
    if dpkg -s "$pkg" > /dev/null 2>&1; then
        INSTALLED["$pkg"]=true
    else
        INSTALLED["$pkg"]=false
    fi
done

apt-get update -y
apt-get install -y --no-install-recommends "${PACKAGES[@]}"

curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /etc/apt/keyrings/llvm.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/${VERSION_CODENAME}/ llvm-toolchain-${VERSION_CODENAME} main" | tee /etc/apt/sources.list.d/llvm.list > /dev/null

for pkg in "${PACKAGES[@]}"; do
    if [ "${INSTALLED[$pkg]}" = "false" ]; then
        apt-get purge --autoremove -y "$pkg"
    fi
done

apt_get_cleanup() {
    rm -rf /var/lib/apt/lists/*
    rm -r /var/lib/apt/lists
}

apt-get update -y
apt-get -y install --no-install-recommends clang clang-format clang-tidy
apt_get_cleanup
