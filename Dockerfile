FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '%s\n' \
  'deb https://deb.debian.org/debian trixie main contrib non-free non-free-firmware' \
  'deb https://deb.debian.org/debian-security trixie=security main contrib non-free non-free-firmware' \
  'deb https://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware' \
  > /etc/apt/source.list 

RUN apt update && apt install -y --no-install-recommends \
  live-build debootstrap squashfs-tools xorriso \
  ca-certificates rsync git \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /work
