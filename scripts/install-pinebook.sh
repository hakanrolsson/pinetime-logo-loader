#!/usr/bin/env bash
#  Install Apache Mynewt for Raspberry Pi.  Based on https://mynewt.apache.org/latest/newt/install/newt_linux.html.  

echo "Installing Apache Mynewt for Raspberry Pi..."
set -e  #  Exit when any command fails.
set -x  #  Echo all commands.

#  Versions to install
mynewt_version=mynewt_1_7_0_tag
nimble_version=nimble_1_2_0_tag
mcuboot_version=v1.3.1

#  gcc should be manually installed
echo "***** Skipping gcc-arm-none-eabi..."

#  TODO
# echo "***** Installing gdb..."
# if [ ! -e /usr/bin/arm-none-eabi-gdb ]; then
#     sudo apt install -y gdb-multiarch
#     sudo ln -s /usr/bin/gdb-multiarch /usr/bin/arm-none-eabi-gdb
# fi

#  TODO
#  echo "***** Installing OpenOCD..."
#  cp ~/openocd/src/openocd openocd/bin/openocd
#  sudo chown root openocd/bin/openocd
#  sudo chmod +s openocd/bin/openocd 

#  Install go for building newt
echo "***** Installing go..."
golangpath=/usr/lib/go-1.13.6/bin
if [ ! -e $golangpath/go ]; then
    wget https://dl.google.com/go/go1.13.6.linux-armv6l.tar.gz
    tar xf go*.tar.gz
    sudo mv go /usr/lib/go-1.13.6
    rm go*.tar.gz

    echo export PATH=$golangpath:\$PATH >> ~/.bashrc
    echo export PATH=$golangpath:\$PATH >> ~/.profile
    echo export GOROOT= >> ~/.bashrc
    echo export GOROOT= >> ~/.profile
fi
export PATH=$golangpath:$PATH
#  Prevent mismatch library errors when building newt.
export GOROOT=
go version  #  Should show "go1.13" or later.

#  Change owner from root back to user for the installed packages.
echo "***** Fixing ownership..."
if [ -d "$HOME/.caches" ]; then
    sudo chown -R $USER:$USER "$HOME/.caches"
fi
if [ -d "$HOME/.config" ]; then
    sudo chown -R $USER:$USER "$HOME/.config"
fi
if [ -d "$HOME/opt" ]; then
    sudo chown -R $USER:$USER "$HOME/opt"
fi

#  Build newt in /tmp/mynewt. Copy to /usr/local/bin.
echo "***** Installing newt..."
if [ ! -e /usr/local/bin/newt ]; then
    mynewtpath=/tmp/mynewt
    if [ -d $mynewtpath ]; then
        rm -rf $mynewtpath
    fi
    mkdir $mynewtpath
    pushd $mynewtpath

    git clone --branch $mynewt_version https://github.com/apache/mynewt-newt/
    cd mynewt-newt/
    ./build.sh
    sudo mv newt/newt /usr/local/bin
    popd
fi
newt version  #  Should show "Version: 1.7.0" or later.  Should NOT show "...-dev".

#  echo "***** Installing mynewt..."
#  Remove the existing Mynewt OS in "repos"
#  if [ -d repos ]; then
#      rm -rf repos
#  fi
#  Download Mynewt OS into the current project folder, under "repos" subfolder.
#  newt install -v -f

set +x  #  Stop echoing all commands.
echo ✅ ◾ ️Done!
