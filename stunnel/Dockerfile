FROM alpine:3.2

EXPOSE 5052
RUN apk update \
  && apk add --update stunnel \
  && chmod +x /opt/run-stunnel.sh \
  && rm -rf /tmp/* /var/cache/apk/*
COPY cert /cert
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]
