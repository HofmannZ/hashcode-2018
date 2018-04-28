FROM gcc:latest AS build-env

COPY . /usr/app
WORKDIR /usr/app

RUN gcc -std=c++14 -lstdc++ cpp/src/main.cpp -o cpp/lib/main

ENV INPUT_FILE=tests/1.in
ENV OUTPUT_FILE=tests/1.out

CMD [ ".cpp/lib/main" ]
