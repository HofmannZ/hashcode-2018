FROM gcc:latest AS build-env

COPY . /usr/app
WORKDIR /usr/app

RUN gcc -std=c++14 -lstdc++ src/main.cpp -o lib
RUN chmod 777 lib
RUN chmod 777 runall.sh

CMD ["runall.sh"]
