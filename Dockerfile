FROM debian:buster-slim

VOLUME /root/workspace
WORKDIR /root/workspace

RUN set -eux; \
	dpkg --add-architecture i386; \
	apt-get update; \
	apt-get install -y --no-install-recommends build-essential ca-certificates \
		file gdb gdbserver git less libc6:i386 libc6-dev:i386 libffi-dev \
		libssl-dev libstdc++6:i386 nano procps python3 python3-dev python3-pip \
		python3-setuptools tmux tzdata wget xxd; \
	rm -rf /var/lib/apt/lists/*

ARG PWNDBG_VERSION="2019.12.09"
ARG PWNDBG_DOWNLOAD_URL="https://github.com/pwndbg/pwndbg/archive/${PWNDBG_VERSION}.tar.gz"
ARG PWNDBG_DOWNLOAD_SHA="235874aa50e23f2400e53d0b31715790ca0c990796a402cdcb881e5d927ce416"
RUN set -eux; \
	wget -qO pwndbg.tar.gz "${PWNDBG_DOWNLOAD_URL}"; \
	echo "${PWNDBG_DOWNLOAD_SHA} pwndbg.tar.gz" | sha256sum --quiet -c; \
	mkdir -p /opt/pwndbg; \
	tar -xzf pwndbg.tar.gz -C /opt/pwndbg --strip-components=1; \
	pip3 install --no-cache-dir -r /opt/pwndbg/requirements.txt; \
	rm -f pwndbg.tar.gz

# ROPgadget is a dependency of pwntools, so install it in its own layer prior
ARG ROPGADGET_VERSION="6.2"
RUN pip3 install --no-cache-dir ropgadget==${ROPGADGET_VERSION}

ARG PWNTOOLS_VERSION="4.0.1"
RUN pip3 install --no-cache-dir pwntools==${PWNTOOLS_VERSION}

ARG RADARE2_VERSION="4.3.1"
ARG RADARE2_DOWNLOAD_URL="http://radare.mikelloc.com/get/${RADARE2_VERSION}/radare2_${RADARE2_VERSION}_amd64.deb"
ARG RADARE2_DOWNLOAD_SHA="d72170c5dcfdc10eed604f9e33b2868107aee6db564152eb63cab78b1d066aa7"
RUN set -eux; \
	wget -qO radare2.deb "${RADARE2_DOWNLOAD_URL}"; \
	echo "${RADARE2_DOWNLOAD_SHA} radare2.deb" | sha256sum --quiet -c; \
	dpkg -i radare2.deb; \
	apt-get update; \
	apt-get install -f; \
	rm -rf radare2.deb /var/lib/apt/lists/*

COPY .gdbinit /root/

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/usr/bin/tmux"]