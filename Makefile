
################################################################################
# Specify directories
BIN_DIR = $(shell pwd)/build/bin

export PATH := $(BIN_DIR):$(PATH)
export PKG_CONFIG_PATH := $(BIN_DIR)/lib/pkgconfig:$(PATH)

################################################################################
# Executables
RM = rm -rf

################################################################################
# Build settings
MAKE_J = $(shell nproc)

################################################################################
# Specify versions
NASM_TAG = 2.14.02
YASM_TAG = 1.3.0
LAME_TAG = 3.100
FFMPEG_TAG = 4.2.1

################################################################################
# NASM
NASM = build/bin/nasm
NASM_DIR = build/nasm-$(NASM_TAG)
NASM_TAR = build/nasm-$(NASM_TAG).tar.bz2
NASM_URL = https://www.nasm.us/pub/nasm/releasebuilds/$(NASM_TAG)/nasm-$(NASM_TAG).tar.bz2

$(NASM_TAR):
	mkdir -p $(@D)
	curl -L $(NASM_URL) -o $@

$(NASM_DIR): $(NASM_TAR)
	mkdir -p $@
	tar -xjvf $< --strip-components=1 --directory=$@

$(NASM): $(NASM_DIR)
	cd $(NASM_DIR) && ./autogen.sh
	cd $(NASM_DIR) && ./configure --prefix="$(BIN_DIR)" --bindir=$(BIN_DIR)
	make -C $< -j$(MAKE_J)
	make -C $< install

clean-nasm:
	$(RM) $(NASM_DIR) build/$(NASM_TAR) $(NASM)

nasm: $(NASM)


################################################################################
# YASM
YASM = build/bin/yasm
YASM_DIR = build/yasm-$(YASM_TAG)
YASM_TAR = build/yasm-$(YASM_TAG).tar.gz
YASM_URL = https://www.tortall.net/projects/yasm/releases/yasm-$(YASM_TAG).tar.gz

$(YASM_TAR):
	mkdir -p $(@D)
	curl -L $(YASM_URL) -o $@

$(YASM_DIR): $(YASM_TAR)
	mkdir -p $@
	tar -xzvf $< --strip-components=1 --directory=$@

$(YASM): $(YASM_DIR)
	cd $(YASM_DIR) && ./configure --prefix="$(BIN_DIR)" --bindir=$(BIN_DIR)
	make -C $< -j$(MAKE_J)
	make -C $< install

clean-yasm:
	$(RM) $(YASM_DIR) build/$(YASM_TAR) $(YASM)

yasm: $(YASM)


################################################################################
# libx264
LIBX264 = build/bin/x264
LIBX264_DIR = build/libx264
LIBX264_URL = https://code.videolan.org/videolan/x264.git
LIBX264_CONFIG = "--enable-static --enable-pic"

$(LIBX264_DIR):
	mkdir -p $@
	git -C build/ clone --depth 1 $(LIBX264_URL) libx264

$(LIBX264): $(LIBX264_DIR)
	PATH="$(BIN_DIR):$PATH" cd $(LIBX264_DIR) && ./configure --prefix="$(BIN_DIR)" --bindir=$(BIN_DIR) $(LIBX264_CONFIG)
	make -C $< -j$(MAKE_J)
	make -C $< install

clean-libx264:
	$(RM) $(LIBX264_DIR) $(LIBX264)

libx264: $(LIBX264)


################################################################################
# libx265
LIBX265 = build/bin/lib/libx265.a
LIBX265_DIR = build/libx265
LIBX265_URL = https://bitbucket.org/multicoreware/x265
LIBX265_CONFIG = "--enable-static --enable-pic"

$(LIBX265_DIR):
	mkdir -p $@
	cd $(LIBX265_DIR) && if hg pull 2> /dev/null; then hg pull && hg update; else hg clone https://bitbucket.org/multicoreware/x265 .; fi

$(LIBX265): $(LIBX265_DIR)
	cd $(LIBX265_DIR) && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$(BIN_DIR)" -DENABLE_SHARED=off source/
	make -C $< -j$(MAKE_J)
	make -C $< install

clean-libx265:
	$(RM) $(LIBX265_DIR) $(LIBX265)

libx265: $(LIBX265)

################################################################################
# LIBVPX
LIBVPX = build/bin/lib/libvpx.a
LIBVPX_DIR = build/libvpx
LIBVPX_URL = https://chromium.googlesource.com/webm/libvpx.git
LIBVPX_CONFIG = --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm

$(LIBVPX_DIR):
	mkdir -p $@
	git -C build/ clone --depth 1 $(LIBVPX_URL) libvpx

$(LIBVPX): $(LIBVPX_DIR)
	cd $(LIBVPX_DIR) && ./configure --prefix="$(BIN_DIR)" $(LIBVPX_CONFIG)
	make -C $< -j$(MAKE_J)
	make -C $< install

clean-libvpx:
	$(RM) $(LIBVPX_DIR) $(LIBVPX)

libvpx: $(LIBVPX)

################################################################################
# libfdk-aac
LIBFDK_AAC = build/bin/lib/libfdk-aac.a
LIBFDK_AAC_DIR = build/LIBFDK_AAC
LIBFDK_AAC_URL = https://github.com/mstorsjo/fdk-aac
LIBFDK_AAC_CONFIG = "--disable-shared"

$(LIBFDK_AAC_DIR):
	mkdir -p $@
	git -C build/ clone --depth 1 $(LIBFDK_AAC_URL) LIBFDK_AAC

$(LIBFDK_AAC): $(LIBFDK_AAC_DIR)
	cd $(LIBFDK_AAC_DIR) && autoreconf -fiv 
	cd $(LIBFDK_AAC_DIR) && ./configure --prefix="$(BIN_DIR)" --bindir=$(BIN_DIR) $(LIBFDK_AAC_CONFIG)
	make -C $< -j$(MAKE_J)
	make -C $< install

clean-libfdk-aac:
	$(RM) $(LIBFDK_AAC_DIR) $(LIBFDK_AAC)

libfdk-aac: $(LIBFDK_AAC)

################################################################################
# libmp3lame
LIBMP3LAME = build/bin/lib/libmp3lame.a
LIBMP3LAME_DIR = build/lame-$(LAME_TAG)
LIBMP3LAME_TAR = build/lame-$(LAME_TAG).tar.gz
LIBMP3LAME_URL = https://downloads.sourceforge.net/project/lame/lame/$(LAME_TAG)/lame-$(LAME_TAG).tar.gz
LIBMP3LAME_CONFIG = --disable-shared --enable-nasm

$(LIBMP3LAME_TAR):
	mkdir -p $(@D)
	curl -L $(LIBMP3LAME_URL) -o $@

$(LIBMP3LAME_DIR): $(LIBMP3LAME_TAR)
	mkdir -p $@
	tar -xzvf $< --strip-components=1 --directory=$@

$(LIBMP3LAME): $(LIBMP3LAME_DIR)
	cd $(LIBMP3LAME_DIR) && ./configure --prefix="$(BIN_DIR)" --bindir=$(BIN_DIR) $(LIBMP3LAME_CONFIG)
	make -C $< -j$(MAKE_J)
	make -C $< install

clean-libmp3lame:
	$(RM) $(LIBMP3LAME_DIR) build/$(LIBMP3LAME_TAR) $(LIBMP3LAME)

libmp3lame: $(LIBMP3LAME)


################################################################################
# libopus
LIBOPUS = build/bin/lib/libopus.a
LIBOPUS_DIR = build/libopus
LIBOPUS_URL = https://github.com/xiph/opus.git
LIBOPUS_CONFIG = "--disable-shared"

$(LIBOPUS_DIR):
	mkdir -p $@
	git -C build/ clone --depth 1 $(LIBOPUS_URL) libopus

$(LIBOPUS): $(LIBOPUS_DIR)
	cd $(LIBOPUS_DIR) && ./autogen.sh
	cd $(LIBOPUS_DIR) && ./configure --prefix="$(BIN_DIR)" $(LIBOPUS_CONFIG)
	make -C $< -j$(MAKE_J)
	make -C $< install

clean-libopus:
	$(RM) $(LIBOPUS_DIR) $(LIBOPUS)

libopus: $(LIBOPUS)

################################################################################
# libaom
LIBAOM = build/bin/bin/aomenc
LIBAOM_DIR = build/libaom
LIBAOM_URL = https://aomedia.googlesource.com/aom
LIBAOM_CONFIG = -DENABLE_SHARED=off -DENABLE_NASM=on

$(LIBAOM_DIR):
	mkdir -p $@
	git -C build/ clone --depth 1 $(LIBAOM_URL) libaom

$(LIBAOM): $(LIBAOM_DIR)
	mkdir -p $(LIBAOM_DIR)/build
	cd $(LIBAOM_DIR)/build && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$(BIN_DIR)" $(LIBAOM_CONFIG) ../
	make -C $</build -j$(MAKE_J)
	make -C $</build install

clean-libaom:
	$(RM) $(LIBAOM_DIR) $(LIBAOM)

libaom: $(LIBAOM)

################################################################################
# nv-codec-headers
NV_CODEC_HEDAERS = build/bin/nv-codec-headers
NV_CODEC_HEDAERS_DIR = build/nv-codec-headers
NV_CODEC_HEDAERS_URL = https://git.videolan.org/git/ffmpeg/nv-codec-headers.git

$(NV_CODEC_HEDAERS_DIR):
	mkdir -p $@
	git -C build/ clone --depth 1 $(NV_CODEC_HEDAERS_URL) nv-codec-headers

$(NV_CODEC_HEDAERS): $(NV_CODEC_HEDAERS_DIR)
	mkdir -p $(NV_CODEC_HEDAERS_DIR)/build
	make -C $< -j$(MAKE_J)
	make -C $< PREFIX=$(BIN_DIR) install

clean-nv-codec-headers:
	$(RM) $(NV_CODEC_HEDAERS_DIR) $(NV_CODEC_HEDAERS)

nv-codec-headers: $(NV_CODEC_HEDAERS)

################################################################################
# zimg
Z_IMG = build/bin/zimg
Z_IMG_DIR = build/zimg
Z_IMG_URL = https://github.com/sekrit-twc/zimg.git

$(Z_IMG_DIR):
	mkdir -p $@
	git -C build/ clone --depth 1 $(Z_IMG_URL) zimg

$(Z_IMG): $(Z_IMG_DIR)
	cd $(Z_IMG_DIR) && ./autogen.sh
	cd $(Z_IMG_DIR) && ./configure --prefix="$(BIN_DIR)" --bindir=$(BIN_DIR) --disable-shared --enable-static
	make -C $< -j$(MAKE_J)
	make -C $< install
	rm $(BIN_DIR)/lib/libzimg.so.2
	rm $(BIN_DIR)/lib/libzimg.so
	cp $(BIN_DIR)/lib/libzimg.so.2.0.0 $(BIN_DIR)/lib/libzimg.so.2
	cp $(BIN_DIR)/lib/libzimg.so.2.0.0 $(BIN_DIR)/lib/libzimg.so

clean-z-img:
	$(RM) $(Z_IMG_DIR) $(Z_IMG)

z-img: $(Z_IMG)

################################################################################
# ffmpeg
FFMPEG = build/bin/ffmpeg
FFMPEG_DIR = build/ffmpeg-$(FFMPEG_TAG)
FFMPEG_TAR = build/ffmpeg-$(FFMPEG_TAG).tar.gz
FFMPEG_URL = https://ffmpeg.org/releases/ffmpeg-$(FFMPEG_TAG).tar.gz

FFMPEG_CONFIG = --disable-shared
FFMPEG_CONFIG += --pkg-config-flags="--static"
FFMPEG_CONFIG += --extra-cflags="-I$(BIN_DIR)/include"
FFMPEG_CONFIG += --extra-ldflags="-L$(BIN_DIR)/lib"
FFMPEG_CONFIG += --extra-libs="-lpthread -lm"
FFMPEG_CONFIG += --enable-gpl
FFMPEG_CONFIG += --enable-libaom
FFMPEG_CONFIG += --enable-libass
FFMPEG_CONFIG += --enable-libfdk-aac
FFMPEG_CONFIG += --enable-libfreetype
FFMPEG_CONFIG += --enable-libmp3lame
FFMPEG_CONFIG += --enable-libopus
FFMPEG_CONFIG += --enable-libvorbis
FFMPEG_CONFIG += --enable-libvpx
FFMPEG_CONFIG += --enable-libx264
FFMPEG_CONFIG += --enable-libx265
FFMPEG_CONFIG += --enable-nonfree
FFMPEG_CONFIG += --enable-libzimg

$(FFMPEG_TAR):
	mkdir -p $(@D)
	curl -L $(FFMPEG_URL) -o $@

$(FFMPEG_DIR): $(FFMPEG_TAR)
	mkdir -p $@
	tar -xzvf $< --strip-components=1 --directory=$@

$(FFMPEG): $(NASM) $(YASM) $(LIBX264) $(LIBX265) $(LIBVPX) $(LIBFDK_AAC) $(LIBMP3LAME) $(LIBOPUS) $(LIBAOM) $(Z_IMG) $(FFMPEG_DIR)
	cd $(FFMPEG_DIR) && ./configure --prefix="$(BIN_DIR)" --bindir=$(BIN_DIR) $(FFMPEG_CONFIG)
	make -C $(FFMPEG_DIR) -j$(MAKE_J)
	make -C $(FFMPEG_DIR) install

clean-ffmpeg:
	$(RM) $(FFMPEG_DIR) build/$(FFMPEG_TAR) $(FFMPEG)

ffmpeg: $(FFMPEG)

################################################################################
# General targets
all: $(FFMPEG)

clean:
	$(RM) $(BIN_DIR)

clean-all:
	$(RM) build
