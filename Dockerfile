# multiple build stages in order of change frequency instead of dependency, so
# updating the server does not require installing build/deploy packages, and
# updating the game does not require building the server

FROM lsiobase/alpine:3.10 AS deploy-base

ENV \
HOME="/config" \
MINETEST_SUBGAME_PATH="/config/.minetest/games" \
WORLD_NAME="world" \
BACKEND="sqlite" \
PG_HOST="" \
PG_DB="mt" \
PG_USER="mt" \
PG_PASS="mt" \
PG_PORT=5432

RUN apk add --no-cache \
	curl \
	gmp \
	libgcc \
	libintl \
	libpq \
	libstdc++ \
	luajit \
	lua-socket \
	sqlite \
	sqlite-libs

FROM deploy-base AS build-base

RUN apk add --no-cache \
	bzip2-dev \
	cmake \
	curl-dev \
	doxygen \
	g++ \
	gcc \
	gettext-dev \
	git \
	gmp-dev \
	icu-dev \
	irrlicht-dev \
	libjpeg-turbo-dev \
	libogg-dev \
	libpng-dev \
	libressl-dev \
	libtool \
	libvorbis-dev \
	luajit-dev \
	make \
	mesa-dev \
	openal-soft-dev \
	postgresql-dev \
	python-dev \
	sqlite-dev

FROM build-base as build-server

COPY ./minetest/ /usr/src/minetest

# free up some space
RUN rm -Rf /usr/src/minetest/games/minetest_game

RUN	mkdir -p /usr/src/minetest/cmakebuild \
	&& cd /usr/src/minetest/cmakebuild \
	&& cmake .. \
	-DBUILD_CLIENT=FALSE \
	-DBUILD_SERVER=TRUE \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCUSTOM_BINDIR=/usr/bin \
	-DCUSTOM_DOCDIR=/usr/share/doc/minetest \
	-DCUSTOM_SHAREDIR=/usr/share/minetest \
	-DENABLE_GETTEXT=FALSE \
	-DENABLE_LUAJIT=TRUE \
	-DENABLE_POSTGRESQL=TRUE \
	-DENABLE_SYSTEM_GMP=TRUE \
	-DENABLE_SYSTEM_JSONCPP=TRUE \
	-DPOSTGRESQL_CONFIG_EXECUTABLE=/usr/bin/pg_config \
	-DPOSTGRESQL_LIBRARY=/usr/lib/libpq.so \
	-DRUN_IN_PLACE=FALSE \
	&& make -j2

RUN cd /usr/src/minetest/cmakebuild \
	&& make install

FROM deploy-base

COPY --from=build-server /usr/share/minetest /usr/share/minetest
COPY --from=build-server /usr/bin/minetestserver /usr/bin/minetestserver
COPY --from=build-server /usr/src/minetest/minetest.conf.example /defaults/minetest.conf

# add local files
COPY ./root /

WORKDIR /config/

EXPOSE 30000/udp

VOLUME /config/.minetest
