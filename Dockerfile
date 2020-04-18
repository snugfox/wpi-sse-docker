FROM debian:buster-slim

VOLUME /root/workspace
WORKDIR /root/workspace

ENV LANG="C.UTF-8"

RUN set -eux; \
	dpkg --add-architecture i386; \
	apt-get update; \
	apt-get install -y --no-install-recommends build-essential ca-certificates \
		cmake file gdb gdbserver git less libc6:i386 libc6-dev:i386 libffi-dev \
		libssl-dev libstdc++6:i386 ltrace nano procps python3 python3-dev \
		python3-pip python3-setuptools strace tmux tzdata wget xxd; \
	rm -rf /var/lib/apt/lists/*

ARG GEF_VERSION="2020.03-1"
ARG GEF_DOWNLOAD_URL="https://raw.githubusercontent.com/hugsy/gef/${GEF_VERSION}/gef.py"
ARG GEF_DOWNLOAD_SHA="d9660b85f56b7f1325814edd661146135bc85ba633aae9c097cc42aed87b2edf"
RUN set -eux; \
	wget -qO /root/.gdbinit-gef.py "${GEF_DOWNLOAD_URL}"; \
	echo "${GEF_DOWNLOAD_SHA} /root/.gdbinit-gef.py" | sha256sum --quiet -c

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

ARG ANGR_VERSION="8.20.1.7"
ARG PWNTOOLS_VERSION="4.0.1"
ARG R2PIPE_VERSION="1.4.2"
ARG ROPGADGET_VERSION="6.2"
ARG CAPSTONE_VERSION="4.0.1"
ARG KEYSTONE_ENGINE_VERSION="0.9.1-3"
ARG ROPPER_VERSION="1.13.3"
ARG UNICORN_VERSION="1.0.1"
RUN pip3 install --no-cache-dir angr==${ANGR_VERSION} \
	pwntools==${PWNTOOLS_VERSION} r2pipe==${R2PIPE_VERSION} \
	ropgadget==${ROPGADGET_VERSION} \
	# Optional dependencies for GEF
	capstone==${CAPSTONE_VERSION} keystone-engine==${KEYSTONE_ENGINE_VERSION} \
	ropper==${ROPPER_VERSION} unicorn==${UNICORN_VERSION}

COPY .gdbinit /root/

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/bin/bash"]
