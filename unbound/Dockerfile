ARG IMAGE_BUILD_DATE="2025-9-24" \
  ALPINE_VERSION="3.22.1" \
  UNBOUND_VERSION="1.24.0" \
  IMAGE_REVISION="0" \
  UNBOUND_UID="1000" \
  UNBOUND_GID="1000"  

FROM alpine:"${ALPINE_VERSION}" AS buildenv

ARG UNBOUND_VERSION \
  UNBOUND_UID \
  UNBOUND_GID

ENV UNBOUND_VERSION="${UNBOUND_VERSION}" \
  UNBOUND_DOWNLOAD_URL="https://www.nlnetlabs.nl/downloads/unbound/unbound-"${UNBOUND_VERSION}".tar.gz" \
  INTERNIC_PGP="F0CB1A326BDF3F3EFA3A01FA937BB869E3A238C5" \
  UNBOUND_PGP_WIJNGAARDS="EDFAA3F2CA4E6EB05681AF8E9F6F1C2D7E045F8D" \
  UNBOUND_PGP_GEORGE="948EB42322C5D00B79340F5DCFF3344D9087A490" \
  UNBOUND_UID="${UNBOUND_UID}" \
  UNBOUND_GID="${UNBOUND_GID}"

WORKDIR /tmp/src

RUN set -xe; \
  addgroup -S -g "${UNBOUND_GID}" _unbound && \
  adduser -S -H -h /usr/local/unbound -g _unbound -u "${UNBOUND_UID}" -D -G _unbound _unbound && \
  apk --update --no-cache add \
  ca-certificates \
  gnupg \
  curl \
  file \ 
  binutils && \
  apk --update --no-cache add --virtual .build-deps \
    build-base\
    libsodium-dev \
    linux-headers \
    openssl-dev \
    nghttp2-dev \
    ngtcp2-dev \
    libevent-dev \
    expat-dev \
    protobuf-c-dev \
    hiredis-dev \
    apk-tools \
  && curl -sSL ${UNBOUND_DOWNLOAD_URL} -o unbound.tar.gz \
  && curl -sSL ${UNBOUND_DOWNLOAD_URL}.asc -o unbound.tar.gz.asc \
  && curl -sSL ${UNBOUND_DOWNLOAD_URL}.sha256 -o unbound.tar.gz.sha256 \
  && echo "`cat unbound.tar.gz.sha256` unbound.tar.gz" | sha256sum -c - \
  && GNUPGHOME="$(mktemp -d)" \
  && export GNUPGHOME \
    && gpg --no-tty --keyserver hkps://keys.openpgp.org --recv-keys "${UNBOUND_PGP_WIJNGAARDS}" "${UNBOUND_PGP_GEORGE}" \
#  && gpg --no-tty --recv-keys "${UNBOUND_PGP_WIJNGAARDS}" "${UNBOUND_PGP_GEORGE}" \
  && gpg --batch --verify unbound.tar.gz.asc unbound.tar.gz \
  && tar -xzf unbound.tar.gz \
  && rm unbound.tar.gz \
  && cd unbound-"${UNBOUND_VERSION}" && \
  ./configure \
    --prefix=/usr/local/unbound/unbound.d \
    --with-run-dir=/usr/local/unbound/unbound.d \
    --with-conf-file=/usr/local/unbound/unbound.conf \
    --with-pidfile=/usr/local/unbound/unbound.d/unbound.pid \
    --mandir=/usr/share/man \
    --with-rootkey-file=/usr/local/unbound/iana.d/root.key \
    --with-ssl \
    --with-libevent \
    --with-libnghttp2 \
    --with-libhiredis \
    --with-username=_unbound \
    --disable-shared \
    --enable-dnstap \
    --enable-dnscrypt \
    --enable-cachedb \
    --with-pthreads \
    --without-pythonmodule \
    --without-pyunbound \
    --enable-event-api \
    --enable-tfo-server \
    --enable-tfo-client \
    --enable-pie \
    --enable-relro-now && \
  make && \
  make install && \
  mkdir -p \
    "/usr/local/unbound/iana.d/"

RUN curl -sSL https://www.internic.net/domain/named.cache -o /usr/local/unbound/iana.d/root.hints && \
  curl -sSL https://www.internic.net/domain/named.cache.md5 -o /usr/local/unbound/iana.d/root.hints.md5 && \
  curl -sSL https://www.internic.net/domain/named.cache.sig -o /usr/local/unbound/iana.d/root.hints.sig && \
  ROOT_HINTS_MD5=`cat /usr/local/unbound/iana.d/root.hints.md5` && \
  echo "${ROOT_HINTS_MD5} */usr/local/unbound/iana.d/root.hints" | md5sum -c - && \
  curl -sSL https://www.internic.net/domain/root.zone -o /usr/local/unbound/iana.d/root.zone && \
  curl -sSL https://www.internic.net/domain/root.zone.md5 -o /usr/local/unbound/iana.d/root.zone.md5 && \
  curl -sSL https://www.internic.net/domain/root.zone.sig -o /usr/local/unbound/iana.d/root.zone.sig && \
  ROOT_ZONE_MD5=`cat /usr/local/unbound/iana.d/root.zone.md5` && \
  echo "${ROOT_ZONE_MD5} */usr/local/unbound/iana.d/root.zone" | md5sum -c - && \
  GNUPGHOME="$(mktemp -d)" && \
  export GNUPGHOME && \
  gpg --no-tty --keyserver hkps://keys.openpgp.org --recv-keys "$INTERNIC_PGP" && \
  gpg --verify /usr/local/unbound/iana.d/root.hints.sig /usr/local/unbound/iana.d/root.hints && \
  gpg --verify /usr/local/unbound/iana.d/root.zone.sig /usr/local/unbound/iana.d/root.zone && \
    /usr/local/unbound/sbin/unbound-anchor -v -a /usr/local/unbound/iana.d/root.key || true && \
  pkill -9 gpg-agent && \
  pkill -9 dirmngr 

COPY ./rootfs/ /
  
RUN set -xe; \
    apk --update --no-cache add \
    ca-certificates \
    tzdata \
    libsodium \
    nghttp2 \
    ngtcp2 \
    libevent \
    openssl \
    protobuf-c \
    hiredis \
    expat && \
    # for the root.* updated
    curl \
    gpg \
    perl \
    # to tune unbound conf
    coreutils \
    libattr \
    utmps-libs \
    skalibs-libs \
  apk --purge del apk-tools && \
  mkdir -p \   
    "/usr/local/unbound/conf.d/" \
    "/usr/local/unbound/certs.d/" \
    "/usr/local/unbound/zones.d/" \
    "/usr/local/unbound/log.d/" && \
  touch /usr/local/unbound/log.d/unbound.log && \  
  chown -R _unbound:_unbound \
    /usr/local/unbound/ && \
  ln -s /dev/random /dev/urandom /dev/null \
    /usr/local/unbound/unbound.d/ && \
  chown -Rh _unbound:_unbound \
    /usr/local/unbound/unbound.d/random \
    /usr/local/unbound/unbound.d/null \
    /usr/local/unbound/unbound.d/urandom && \
  chmod -R 770 \
    /usr/local/unbound/sbin/*.sh && \
  rm -rf \  
    /tmp/* \
    /var/tmp/* \
    /var/log/* \
    /usr/local/unbound/unbound.d/share \
    /usr/local/unbound/etc \    
    /usr/local/unbound/unbound.conf \
    /usr/local/unbound/iana.d/root.hints.* \
    /usr/local/unbound/iana.d/root.zone.* \
    /usr/local/unbound/unbound.d/include \
    /usr/local/unbound/unbound.d/lib && \
    strip --strip-all /usr/local/unbound/unbound.d/sbin/unbound && \
    strip --strip-all /usr/local/unbound/unbound.d/sbin/unbound-anchor && \
    strip --strip-all /usr/local/unbound/unbound.d/sbin/unbound-checkconf  && \
    strip --strip-all /usr/local/unbound/unbound.d/sbin/unbound-control && \
    strip --strip-all /usr/local/unbound/unbound.d/sbin/unbound-host \
    # enable root.hints and root.zone updated via crontab
    && (crontab -l 2>/dev/null; echo "0 0 * * 0 /bin/bash /usr/local/unbound/sbin/01-update_root_hints.sh && unbound-control reload") | crontab - \
    && (crontab -l 2>/dev/null; echo "0 0 * * 0 /bin/bash /usr/local/unbound/sbin/01-update_root_zone.sh && unbound-control reload") | crontab - \
    && (crontab -l 2>/dev/null; echo "5 0 * * 0 /bin/bash /usr/local/unbound/sbin/02-check_signature.sh && unbound-control reload") | crontab -

COPY ./rootfs/usr/local/unbound/unbound.conf \
      /usr/local/unbound/unbound.conf 

FROM scratch AS stage   

COPY --from=buildenv /usr/local/unbound/ \
    /app/usr/local/unbound/
 
COPY --from=buildenv /lib/*-musl-* \
    /app/lib/

COPY --from=buildenv /bin/sh /bin/sed \
    /app/bin/

# for healthcheck.sh
COPY --from=buildenv /usr/bin/nslookup /usr/bin/awk \
    /app/bin/

# for ssl
COPY --from=buildenv /usr/lib/libgcc_s* \
    /usr/lib/libsodium* \
    /usr/lib/libcrypto* \
    /usr/lib/libssl* \
    /usr/lib/libexpat* \
    /usr/lib/libprotobuf-c* \
    /usr/lib/libnghttp2* \
    /usr/lib/libhiredis* \
    /usr/lib/libevent* \
    /usr/lib/libngtcp2* \
    /app/usr/lib/
 
COPY --from=buildenv /etc/ssl/ \
  /app/etc/ssl/
  
# for root.* updated
COPY --from=buildenv /usr/bin/curl /usr/bin/gpg /usr/bin/dirmngr /usr/bin/md5sum /usr/bin/nproc /usr/bin/perl \
        /app/usr/bin/
    
# for tuning unbound
COPY --from=buildenv  /usr/bin/nproc /usr/bin/perl \
        /app/usr/bin/

COPY --from=buildenv /usr/lib/libacl* /usr/lib/libattr* /usr/lib/libutmps*  /usr/lib/libskarnet* \
        /app/usr/lib/

COPY --from=buildenv  /usr/lib/perl5/core_perl/CORE/libperl* \
        /app/usr/lib/perl5/core_perl/CORE/

# for changing user
COPY --from=buildenv /etc/passwd /etc/group \
    /app/etc/
 
# for TZ
COPY --from=buildenv /usr/share/zoneinfo/ \
  /app/usr/share/zoneinfo/

WORKDIR /

FROM scratch AS unbound

ARG UNBOUND_VERSION \
  ALPINE_VERSION \
  IMAGE_BUILD_DATE \
  IMAGE_REVISION \
  UNBOUND_UID 

ENV BUILD_DATE="${IMAGE_BUILD_DATE}" \
  IMAGE_REVISION="${IMAGE_REVISION}" \
  UNBOUND_VERSION="${UNBOUND_VERSION}" \
  ALPINE_VERSION="${ALPINE_VERSION}" \
  UNBOUND_UID="${UNBOUND_UID}" \
  PATH=/usr/local/unbound/unbound.d/sbin:"$PATH" 
  
LABEL maintainer="megavolts" \
  org.opencontainers.image.title="megavolts/hassio-addons/unbound" \
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.version="${UNBOUND_VERSION}" \
  org.opencontainers.image.revision="${IMAGE_REVISION}" \
  org.opencontainers.image.description="Unbound is a validating, recursive, and caching DNS resolver." \
  org.opencontainers.image.summary="This multiarch Unbound Docker image is based on Alpine Linux with focus on security, privacy, performance and a small image size. And with Pi-hole in mind." \
  org.opencontainers.image.base.name="https://hub.docker.com/r/megavolts/unbound-docker-haos:latest" \
  org.opencontainers.image.url="https://hub.docker.com/r/megavolts/hassio-addons/unbound" \
  org.opencontainers.image.source="https://github.com/megavolts/hassio-addons/unbound" \
  org.opencontainers.image.authors="madnuttah" \
  org.opencontainers.image.licenses="MIT"

COPY --from=stage /app/ /

USER "${UNBOUND_UID}"

CMD [ "/usr/local/unbound/sbin/unbound.sh" ]
