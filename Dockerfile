FROM alpine:3.15

RUN apk --no-cache add git bash~=5.1

RUN rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
