source $stdenv/setup

tar xfz $src

mkdir build
cd build
../gcc-$VERSION/configure --target=$TARGET --prefix=$out --disable-nls --enable-languages=c,c++ --without-headers

make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
