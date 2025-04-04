#!/bin/bash
set -euo pipefail

# Path variables
DIR=$(readlink -f .)
MAIN=$(readlink -f ${DIR}/..)

# Set up ccache if not running in GitHub Actions
if [ -z "${GITHUB_ACTIONS-}" ]; then
    mkdir -p "$(pwd)/.ccache"
    export CCACHE_DIR="$(pwd)/.ccache"
fi
export USE_CCACHE=1

# Setup Clang
export CLANG_PATH=$MAIN/clang-tc/bin/
export PATH=${CLANG_PATH}:${PATH}
export CLANG_TRIPLE="aarch64-linux-gnu-"
export CROSS_COMPILE="aarch64-linux-gnu-"

# Config
THREAD="-j$(nproc --all)"
DEFCONFIG="gki_defconfig"
export ARCH=arm64
export SUBARCH=$ARCH
export KBUILD_BUILD_USER=nobody
LLVM_CONFIG="LLVM=1 LLVM_IAS=1 AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip"

# Build
make ${THREAD} CC="ccache clang" CXX="ccache clang++" ${LLVM_CONFIG} ${DEFCONFIG} O=out
make ${THREAD} CC="ccache clang" CXX="ccache clang++" ${LLVM_CONFIG} CONFIG_LTO_CLANG_THIN=y CONFIG_LTO_CLANG_FULL=n O=out 2>&1 | tee kernel.log
