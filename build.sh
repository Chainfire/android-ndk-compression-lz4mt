#!/bin/sh

if [ -z "$NDK" ]; then
  if [ ! -z "$ANDROID_NDK_ROOT" ]; then
    NDK=$ANDROID_NDK_ROOT
  elif [ ! -z "$NDK_ROOT" ]; then
    NDK=$NDK_ROOT
  else
    NDK=$((find ~/. -maxdepth 1 -type d; find ~/. -maxdepth 1 -type l) | grep "android-ndk" | sort --reverse | grep -m 1 "android-ndk")
    if [ ! -z "$NDK" ]; then
      NDK=$(readlink -f $NDK)
    fi
    if [ -z "$NDK" ]; then
      echo Please set ANDROID_NDK_ROOT
      exit 1
    fi
  fi
fi

if [ -z "$LIBSPATHS" ]; then
  LIBSPATHS=false
fi

if ($LIBSPATHS); then
  # Use paths compatible with Android packaging
  PATH_ARM=armeabi
  PATH_ARMV7=armeabi-v7a
  PATH_ARM64=arm64-v8a
  PATH_X86=x86
  PATH_X64=x86_64
  PATH_MIPS=mips
  PATH_MIPS64=mips64
else
  # Use paths as used by SuperSU ZIP
  PATH_ARM=arm
  PATH_ARMV7=armv7
  PATH_ARM64=arm64
  PATH_X86=x86
  PATH_X64=x64
  PATH_MIPS=mips
  PATH_MIPS64=mips64
fi

# toolchain api arch toolchain
toolchain() {
  local HOST=linux-x86_64
  if [ ! -d "toolchains" ]; then
    mkdir toolchains
  fi
  if [ ! -d "toolchains/$2-$1" ]; then
    $NDK/build/tools/make-standalone-toolchain.sh --platform=android-$1 --arch=$2 --toolchain=$3 --install-dir=toolchains/$2-$1 --system=$HOST --ndk-dir=$NDK --llvm-version=3.6 --stl=libc++
  fi
}

# build api arch toolchain path CFLAGS CXXFLAGS LDFLAGS
build_core() {
  make -C lz4mt clean
  make -C lz4mt -j4 \
    CC="$PWD/toolchains/$2-$1/bin/clang" \
    CXX="$PWD/toolchains/$2-$1/bin/clang++" \
    CFLAGS="-Wall -W -Wextra -pedantic -std=c99 -Os -fdata-sections -ffunction-sections -fvisibility=hidden $5" \
    CXXFLAGS="-Wall -W -Wextra -pedantic -Weffc++ -Wno-missing-field-initializers -std=c++0x -Ilz4/ -Ilz4/programs -Os -fdata-sections -ffunction-sections -fvisibility=hidden $6" \
    LDFLAGS="-Wl,-s -Wl,--gc-sections $7"
  mkdir -p $4
  mv lz4mt/lz4mt $4/lzmt
}

# build api arch toolchain path CFLAGS CXXFLAGS LDFLAGS
build() {
  toolchain $1 $2 $3
  build_core $1 $2 $3 out/dynamic.pie/$4 "$5 -fPIE" "$6 -fPIE" "$7 -pie -fPIE"
  build_core $1 $2 $3 out/static/$4 "$5" "$6" "$7 -static -Wl,--allow-multiple-definition"
}

rm -rf out

build 16 arm arm-linux-androideabi-4.9 $PATH_ARMV7 "-march=armv7-a -mthumb -mfloat-abi=softfp -mfpu=vfpv3-d16" "-march=armv7-a -mthumb -mfloat-abi=softfp -mfpu=vfpv3-d16" "-Wl,--fix-cortex-a8 -latomic"
build 16 x86 x86-4.9 $PATH_X86
build 16 mips mipsel-linux-android-4.9 $PATH_MIPS
build 21 arm64 aarch64-linux-android-4.9 $PATH_ARM64
build 21 x86_64 x86_64-4.9 $PATH_X64
build 21 mips64 mips64el-linux-android-4.9 $PATH_MIPS64

for i in dynamic.pie static; do
  for j in $PATH_ARMV7 $PATH_X86 $PATH_MIPS $PATH_ARM64 $PATH_X64 $PATH_MIPS64; do
    if [ ! -f "out/$i/$j/lzmt" ]; then
       echo missing out/$i/$j/lzmt !
    fi
  done
done

