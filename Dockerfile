# Run octodns-sync with your config.

FROM python:3-slim

RUN apt update && apt install -y git && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/apt/*

RUN pip install git+https://github.com/thattommyhall/octodns@add-plan-checksum
RUN pip install cbor2

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
