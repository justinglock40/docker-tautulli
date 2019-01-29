FROM lsiobase/alpine.python:3.8

# set version label
ARG BUILD_DATE
ARG VERSION
ARG TAUTULLI_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	g++ \
	gcc \
	make \
	python-dev && \
 echo "**** install pip packages ****" && \
 pip install --no-cache-dir -U \
	plexapi \
	pycryptodomex && \
 echo "**** install app ****" && \
 mkdir -p /app/tautulli && \
 if [ -z ${TAUTULLI_RELEASE+x} ]; then \
	TAUTULLI_RELEASE=$(curl -sX GET "https://api.github.com/repos/Tautulli/Tautulli/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/tautulli.tar.gz -L \
	"https://github.com/Tautulli/Tautulli/archive/${TAUTULLI_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/tautulli.tar.gz -C \
	/app/tautulli --strip-components=1 && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# add local files
COPY root/ /

# ports and volumes
VOLUME /config /logs
EXPOSE 8181
