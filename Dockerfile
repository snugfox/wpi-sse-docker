FROM debian:buster-slim

VOLUME /root/workspace
WORKDIR /root/workspace

ENV LANG="C.UTF-8"

RUN set -eux; \
	dpkg --add-architecture i386; \
	apt-get update; \
	apt-get install -y --no-install-recommends build-essential ca-certificates \
		cmake git libc6:i386 libc6-dev:i386 libffi-dev libssl-dev \
		libstdc++6:i386 python3 python3-dev python3-pip python3-setuptools \
		tzdata; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends file gdb gdbserver less nano \
		procps tmux wget xxd; \
	rm -rf /var/lib/apt/lists/*

ARG GEF_VERSION="2020.03-1"
ARG GEF_DOWNLOAD_URL="https://raw.githubusercontent.com/hugsy/gef/${GEF_VERSION}/gef.py"
ARG GEF_DOWNLOAD_SHA="d9660b85f56b7f1325814edd661146135bc85ba633aae9c097cc42aed87b2edf"
RUN set -eux; \
	wget -qO /root/.gdbinit-gef.py "${GEF_DOWNLOAD_URL}"; \
	echo "${GEF_DOWNLOAD_SHA} /root/.gdbinit-gef.py" | sha256sum --quiet -c; \
	pip3 install --no-cache-dir capstone keystone-engine ropper unicorn

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
