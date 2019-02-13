FROM alpine:3.9

# Install dependencies
RUN apk add git m4 libtool autoconf automake make g++ openssl-dev unbound-dev check-dev libbsd-dev yaml-dev doxygen

# Install getdns
RUN git clone https://github.com/getdnsapi/getdns.git && \
    cd getdns && \
    git checkout master && \
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
    autoreconf -vfi && \
    ./configure CFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib" && \
    make && \
    make install && \
    cd / && \
    rm -R stubby

CMD /bin/sh
