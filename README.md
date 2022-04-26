# hs-demo

This is a demo of using Knative using Haskell. It defines 4 services:
```
haskell-fn-events-ping
haskell-fn-events-pong
haskell-fn-serving-ping
haskell-fn-serving-pong
```


`haskell-fn-events-ping` and `haskell-fn-events-pong` can be called from outside
of a cluster using HTTP Get requests. They send events to
`haskell-fn-serving-ping`, `haskell-fn-serving-pong` event handlers. Event
handlers just log received messaged.

Schematically it looks like that:
```
haskell-fn-events-ping -- Ping --> haskell-fn-serving-ping
haskell-fn-events-pong -- Pong --> haskell-fn-serving-pong
```

Messaging is done using Knative's exapmle-broker which comes with `kn quickstart`.

## Build & Deploy

[Optional] Build docker images. This script will build executables locally and copy into docker images:
```
sh docker/build-images-from-local-exe.sh
```

This version builds everything inside of docker images `docker/build-images.sh`.

Deploy
```
kubectl apply -f knative.yaml
```

Watch logs
```
stern haskell-fn-events
```

Send events
```
curl http://haskell-fn-serving-pong.default.127.0.0.1.sslip.io
curl http://haskell-fn-serving-ping.default.127.0.0.1.sslip.io
```

# Changes reconciliation

This is an open question. After any changes doing `kubectl apply -f
knative.yaml` doesn't update services. My guess is that `knative.yaml` should
contain version tags for images so that `kubectl` can understand that service
configuration has changed.

For now, one needs to update services manually:

```
kn service update haskell-fn-serving-ping --image kevroletin/haskell-fn-serving-ping --port 8080
kn service update haskell-fn-serving-pong --image kevroletin/haskell-fn-serving-pong --port 8080
kn service update haskell-fn-events-ping --image kevroletin/haskell-fn-events-ping --port 8080
kn service update haskell-fn-events-pong --image kevroletin/haskell-fn-events-pong --port 8080
```
