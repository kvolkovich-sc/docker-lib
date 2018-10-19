FROM microsoft/azure-cli:2.0.46

ARG NAME
ARG BUILD_DATE
ARG VCS_URL
ARG VCS_REF

LABEL maintainer="kirill.volkovich@scand.com" \
      org.label-schema.name=$NAME \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0"

# Install stuff

RUN apk add --no-cache docker grep sed gawk curl py-pip git bash tar gnupg jq unzip graphviz bind-tools \
	&& pip install httpie \
	&& rm -rf /root/.cache

# Install nodejs

ENV NODE_VERSION 10.12.0

RUN apk add --no-cache
RUN libstdc++
RUN apk add --no-cache --virtual .build-deps
RUN apk add --no-cache --virtual binutils-gold
RUN apk add --no-cache --virtual curl
RUN apk add --no-cache --virtual g++
RUN apk add --no-cache --virtual gcc
RUN apk add --no-cache --virtual gnupg
RUN apk add --no-cache --virtual libgcc
RUN apk add --no-cache --virtual linux-headers
RUN apk add --no-cache --virtual make
RUN apk add --no-cache --virtual python

# gpg keys listed at https://github.com/nodejs/node#release-te;
RUN for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
  ; do \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done
  
RUN curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz"
RUN curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"
RUN gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc
RUN grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c -
RUN tar -xf "node-v$NODE_VERSION.tar.xz"
RUN cd "node-v$NODE_VERSION"
RUN ./configure
RUN make -j$(getconf _NPROCESSORS_ONLN)
RUN make install
RUN apk del .build-deps
RUN cd ..
RUN rm -Rf "node-v$NODE_VERSION"
RUN rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt
	
CMD [ "node" ]
