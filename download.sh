# get the sources
if [ -d "lz4mt" ]; then rm -rf lz4mt; fi
git clone --recursive https://github.com/t-mat/lz4mt.git lz4mt
rm -rf lz4mt/.git*
rm -rf lz4mt/lz4/.git*

# dl.cpp
cp dl.cpp lz4mt/src/dl.cpp

# patch Makefile
sed -i -e '/-lrt -pthread/d' lz4mt/Makefile

