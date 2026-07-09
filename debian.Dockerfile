# LTS - Debian Wiki https://wiki.debian.org/LTS
#   Version,            Released,   LTS schedule
#   Debian 11 bullseye, 2021-08-14, 2024-08-15 - 2026-08-31
#   Debian 12 bookworm, 2023-06-10, 2026-06-11 - 2028-06-30
#   Debian 13 trixie,   2025-08-09, 2028-08-09 - 2030-06-30
# debian - Official Image | Docker Hub https://hub.docker.com/_/debian
#   Debian 11 https://hub.docker.com/_/debian/tags?name=bullseye-
#   Debian 12 https://hub.docker.com/_/debian/tags?name=bookworm-
#   Debian 13 https://hub.docker.com/_/debian/tags?name=trixie-
#   Debian 14 https://hub.docker.com/_/debian/tags?name=forky-
FROM debian:trixie-20260623-slim
ENV LANG C.UTF-8
ENV TZ UTC

RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    procps \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /work
