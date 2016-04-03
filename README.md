#About#

This is a script to download/build lz4mt, using the Android NDK.

- lz4mt - BSD-ish

I make no claims as to how well the output programs in all their variants actually work. I only made sure they built. I need this for a different project, but thought I might share it. If anything breaks, you get to keep all the pieces.

This repo is closely related to my android-ndk-compression-tools repo, but due to the differences in how the binaries are built, lz4mt is not included in that repo.

#Building#

I built all of this on an x86-64 Linux Mint box.

To download the needed sources, run ``./download.sh``. Note that this script makes some minor modifications to the download. Because upstream may change, I included all files as they were at the time of this writing.

To build, run ``./build.sh``.

