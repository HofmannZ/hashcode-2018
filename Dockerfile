FROM launcher.gcr.io/google/ubuntu16_04 AS build-env

COPY . /usr/src
WORKDIR /usr/src

# use clean to execute
FROM launcher.gcr.io/google/ubuntu16_04

COPY --from=build-env /usr/src /usr/src
WORKDIR /usr/src

# start the code
CMD [ "./lib" ]
