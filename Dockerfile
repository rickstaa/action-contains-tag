FROM alpine:3.17

RUN apk --no-cache add git bash

RUN rm -rf /var/lib/apt/lists/*

RUN  apk update
RUN apk add git

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
