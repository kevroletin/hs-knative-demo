FROM ghcr.io/openfaas/of-watchdog:0.9.3 as watchdog
FROM haskell:8.10.7-slim-buster as builder

WORKDIR /app

COPY stack.yaml .
COPY package.yaml .
RUN stack build --system-ghc --only-dependencies

# ---

COPY . .
RUN stack build --system-ghc --copy-bins

FROM debian:buster-slim

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

WORKDIR /root/
COPY --from=builder /root/.local/bin/kubernetes-hs-exe .

ENV fprocess="/root/kubernetes-hs-exe"
ENV write_debug="true"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:3000"
ENV exec_timeout="10s"
ENV write_timeout="15s"
ENV read_timeout="15s"

EXPOSE 8080
HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
