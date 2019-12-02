#!/bin/bash

sudo apt-get update -qq && sudo apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libtool \
  libvorbis-dev \
  pkg-config \
  texinfo \
  wget \
  zlib1g-dev \
  mercurial libnuma-dev

# From the installation guide
make nasm
make yasm
make libx264
make libx265
make libvpx
make libfdk-aac
make libmp3lame
make libopus
make libaom
make z-img
# nv header
make nv-codec-headers
# ffmpeg
make ffmpeg