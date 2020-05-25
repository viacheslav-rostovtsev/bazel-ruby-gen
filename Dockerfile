### Alternatively, start from stretch and install bazel
# FROM buildpack-deps:stretch
# 
# RUN apt-get update \
#     && apt-get install -y --no-install-recommends apt-transport-https

# RUN curl https://bazel.build/bazel-release.pub.gpg | apt-key add - \
#     && echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
#     && apt-get update \
#     && apt-get install -y --no-install-recommends bazel

### Start from bazel and install some dev tools
FROM l.gcr.io/google/bazel:latest

### Requirement: system has git to get the gapic repo
### Requirement: system has make to build ruby
### Requirement: system has zlib and zlib-dev, openssl and openssl-dev, all needed for rubygems to work
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        make \
        zlib1g-dev \
        libssl-dev \ 
    && rm -rf /var/lib/apt/lists/*

### Requirement: Set the correct locale so Ruby strings default to UTF-8, needed for template engine to work
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -f /var/lib/apt/lists/*_*
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en

# For debug
# RUN apt-get install -y --no-install-recommends \
#         strace \
#         less
#     && rm -rf /var/lib/apt/lists/*

### Get the entrypoint and run
WORKDIR /src
COPY docker-entrypoint.sh .

WORKDIR /src/bazel-ruby-gen
ENTRYPOINT /src/docker-entrypoint.sh; /bin/bash
