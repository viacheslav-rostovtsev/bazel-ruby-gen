FROM l.gcr.io/google/bazel:latest
RUN apt-get install make -y
RUN apt-get install strace -y

RUN apt-get install less -y

#RUN apt-get install gcc -y
#RUN export CC=/usr/bin/gcc
#RUN apt-get install zlib1g -y
RUN apt-get install zlib1g-dev -y
RUN apt-get install libssl-dev -y

WORKDIR /src
COPY docker-entrypoint.sh .

WORKDIR /src/bazel-ruby-gen

ENTRYPOINT /src/docker-entrypoint.sh; /bin/bash