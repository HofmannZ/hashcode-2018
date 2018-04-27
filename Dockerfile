FROM gcc:latest AS build-env

COPY . /usr/app
WORKDIR /usr/app

RUN gcc -std=c++14 -lstdc++ src/main.cpp -o lib/main

ENV INPUT_FILE=tests/1.in
ENV OUTPUT_FILE=tests/1.out

CMD [ "./lib/main" ]
