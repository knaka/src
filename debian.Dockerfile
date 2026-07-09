# debian Tags | Docker Hub https://hub.docker.com/_/debian/tags
#   Debian 11 https://hub.docker.com/_/debian/tags?name=bullseye-
#   Debian 12 https://hub.docker.com/_/debian/tags?name=bookworm-
#   Debian 13 https://hub.docker.com/_/debian/tags?name=trixie-
FROM debian:trixie-20260623-slim
ENV LANG C.UTF-8
ENV TZ UTC

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      procps \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /work
