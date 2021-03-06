#!/bin/sh -e

PREFIX="$1"
shift
OPTIMIZE="$*"
OPTIMIZE1=`echo "$*" | sed -s 's;enable-sse2;enable-sse;'`
echo "Optimization for double" ${OPTIMIZE}
echo "Optimization for single" ${OPTIMIZE1}

PFFT_VERSION=1.0.8-alpha-fftw3
TMP="tmp-pfft-$PFFT_VERSION"
LOGFILE="build.log"

mkdir $TMP 
ROOT=`dirname $0`/../
if ! [ -f $ROOT/depends/pfft-$PFFT_VERSION.tar.gz ]; then
wget https://github.com/rainwoodman/pfft/releases/download/$PFFT_VERSION/pfft-$PFFT_VERSION.tar.gz \
    -O $ROOT/depends/pfft-$PFFT_VERSION.tar.gz 
fi

gzip -dc $ROOT/depends/pfft-$PFFT_VERSION.tar.gz | tar xf - -C $TMP
cd $TMP

(
mkdir -p double;cd double

../pfft-${PFFT_VERSION}/configure --prefix=$PREFIX --disable-shared --enable-static  \
--disable-fortran --disable-doc --enable-mpi ${OPTIMIZE} &&
make -j 4   &&
make install && echo "PFFT_DONE"
) 2>&1 > ${LOGFILE}.double

if ! grep PFFT_DONE ${LOGFILE}.double > /dev/null; then
    tail ${LOGFILE}.double
    exit 1
fi
(
mkdir -p single;cd single
../pfft-${PFFT_VERSION}/configure --prefix=$PREFIX --enable-single --disable-shared --enable-static  \
--disable-fortran --disable-doc --enable-mpi $2 ${OPTIMIZE1} &&
make -j 4  &&
make install && echo "PFFT_DONE"
) 2>&1 > ${LOGFILE}.single

if ! grep PFFT_DONE ${LOGFILE}.single > /dev/null; then
    tail ${LOGFILE}.single
    exit 1
fi
