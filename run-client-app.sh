#!/bin/bash

cd go-client-app

export KAFKA_BOOTSTRAP_SERVERS=kafka:9092
export CA_CERT_LOCATION=../certs/ca/ca-cert
export KAFKA_TOPIC=mytopic
export USER_CERT_LOCATION=../certs/client/cli-signed.crt
export USER_KEY_LOCATION=../certs/client/cli.key
export USER_KEY_PASSWORD=changeit

go run main.go
cd -
