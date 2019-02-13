FROM alpine:3.9 AS stubby

ARG getdns_tag=v1.5.1
ARG stubby_tag=v0.2.5

# Install build dependencies
RUN apk add git m4 libtool autoconf automake make g++ openssl-dev unbound-dev check-dev libbsd-dev yaml-dev doxygen

# Install getdns
RUN git clone https://github.com/getdnsapi/getdns.git && \
    cd getdns && \
    git checkout $getdns_tag && \
    git submodule update --init && \
    libtoolize -ci && \
    autoreconf -fi && \
    mkdir build && \
    cd build && \
    ../configure --prefix=/usr/local --without-libidn --without-libidn2 && \
    make && \
    make install && \
    cd / && \
    rm -R getdns

# Install stubby
RUN git clone https://github.com/getdnsapi/stubby.git && \
    cd stubby && \
    git checkout $stubby_tag && \
    autoreconf -vfi && \
    ./configure CFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib" && \
    make && \
    make install && \
    cd / && \
    rm -R stubby

# Uninstall build dependencies
RUN apk del git m4 libtool autoconf automake make g++ openssl-dev unbound-dev check-dev libbsd-dev yaml-dev doxygen

# Install runtime dependencies
RUN apk add yaml libbsd unbound

FROM scratch
COPY --from=stubby / /
CMD /bin/sh
