#!/bin/bash

# === CONFIGURATION ===
PYTHON_VERSION=3.11.8
OPENSSL_VERSION=1.1.1w
LIBFFI_VERSION=3.4.4
APP_PREFIX=$HOME/.app-env
INSTALL_PREFIX="$HOME/.app-env/local"
SRC_DIR="$HOME/.app-env/src"
VENV_PATH="$HOME/.app-env/cocotb-env"

# === DIRECTORIES ===
mkdir -p $SRC_DIR && cd $SRC_DIR

# === Build OpenSSL ===
wget https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
rm -rf openssl-$OPENSSL_VERSION && tar xzf openssl-$OPENSSL_VERSION.tar.gz && cd openssl-$OPENSSL_VERSION
./config --prefix=$APP_PREFIX/openssl --openssldir=$APP_PREFIX/openssl no-shared
make -j$(nproc)
make install

# === Build libffi ===
cd $SRC_DIR
wget https://github.com/libffi/libffi/releases/download/v$LIBFFI_VERSION/libffi-$LIBFFI_VERSION.tar.gz
rm -rf libffi-$LIBFFI_VERSION && tar xzf libffi-$LIBFFI_VERSION.tar.gz && cd libffi-$LIBFFI_VERSION
./configure --prefix=$APP_PREFIX/libffi --disable-shared --enable-static CFLAGS="-fPIC"
make -j$(nproc)
make install

# === Build Python ===
cd $SRC_DIR
wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
rm -rf Python-$PYTHON_VERSION && tar xzf Python-$PYTHON_VERSION.tgz && cd Python-$PYTHON_VERSION

PKG_CONFIG_PATH=$APP_PREFIX/libffi/lib64/pkgconfig \
./configure --prefix=$INSTALL_PREFIX \
            --with-openssl=$APP_PREFIX/openssl \
            --with-system-ffi \
            --enable-shared \
            CPPFLAGS="-I$APP_PREFIX/libffi/include -fPIC" \
            LDFLAGS="-L$APP_PREFIX/libffi/lib64 -Wl,-rpath=$APP_PREFIX/local/lib"
make -j$(nproc)
make install

# === Create and activate virtual environment ===
$INSTALL_PREFIX/bin/python3.11 -m venv $VENV_PATH
source $VENV_PATH/bin/activate

# === Install cocotb ===
pip install --upgrade pip setuptools wheel
pip install cocotb==1.9.2

# === Done ===
echo "✅ Python $PYTHON_VERSION, OpenSSL $OPENSSL_VERSION, libffi $LIBFFI_VERSION, and cocotb installed in virtualenv at $VENV_PATH"

