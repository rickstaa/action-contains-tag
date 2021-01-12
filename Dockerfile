FROM alpine:3.12

RUN apk --no-cache add git bash~=5.0

RUN rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
