The XML files are generated from librdkafka header files as following.
(To get struct definitions for some of the _t (ABI compat) types,
 it's necessary to do some contortions to get castxml to find them.)


export ROOTDIR=/kvmkafka
export TMPDIR=$ROOTDIR/tmp


# BUILD LIBRDKAFKA

# at least for me on Centos 6.8
sudo yum install gcc-c++.x86_64
sudo yum install zlib-devel.x86_64
sudo yum install openssl-devel.x86_64

cd /tmp/
# (for 0.9.1:  wget https://github.com/edenhill/librdkafka/archive/0.9.1.tar.gz )
wget https://github.com/edenhill/librdkafka/archive/v0.9.2.tar.gz
tar -zxf v0.9.2.tar.gz
cd librdkafka-0.9.2/
./configure --prefix=/usr/local/librdkafka-0.9.2
make
sudo make install


Actually the install part isn't needed for this.
We just need the headers to be made (e.g.: #include "../config.h" /* mklove output */).

cd src/
castxml --castxml-gccxml --castxml-cc-gnu-c /usr/bin/gcc -I. -I$ROOTDIR/usr/include -o $TMPDIR/rdkafka-0.9.2.xml $TMPDIR/main.c

(I got a couple warnings that I don't care about.)
