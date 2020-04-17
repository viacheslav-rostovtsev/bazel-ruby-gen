FROM l.gcr.io/google/bazel:latest
RUN apt-get install make -y
RUN apt-get install gcc -y
RUN export CC=/usr/bin/gcc

WORKDIR /src
RUN git clone https://github.com/viacheslav-rostovtsev/bazel-ruby-gen.git

WORKDIR /src/bazel-ruby-gen
RUN git checkout --track origin/dev/virost/tech_heresy/build_gems