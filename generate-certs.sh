#!/bin/bash

PASSWORD="changeit"

rm -Rf certs
mkdir -p certs/{ca,server,client}

# CA
openssl req -new -newkey rsa:4096 -days 365 -x509 -subj "/CN=My Company" -keyout certs/ca/ca-key -out certs/ca/ca-cert -nodes

# --- SERVER --- 
# KeyStore
keytool -genkey -keystore certs/server/server.keystore.jks -validity 365 -storepass $PASSWORD -keypass $PASSWORD -dname "CN=kafka" -storetype pkcs12

# CSR
keytool -keystore certs/server/server.keystore.jks -certreq -file certs/server/csr -storepass $PASSWORD -keypass $PASSWORD

# CSR Signed with the CA
openssl x509 -req -CA certs/ca/ca-cert -CAkey certs/ca/ca-key -in certs/server/csr -out certs/server/csr-signed -days 365 -CAcreateserial -passin pass:$PASSWORD

# Import CA certificate in KeyStore
keytool -keystore certs/server/server.keystore.jks -alias CARoot -import -file certs/ca/ca-cert -storepass $PASSWORD -keypass $PASSWORD -noprompt

# Import Signed CSR In KeyStore
keytool -keystore certs/server/server.keystore.jks -import -file certs/server/csr-signed -storepass $PASSWORD -keypass $PASSWORD -noprompt

# Import CA certificate In TrustStore
keytool -keystore certs/server/server.truststore.jks -alias CARoot -import -file certs/ca/ca-cert -storepass $PASSWORD -keypass $PASSWORD -noprompt


# --- CLIENT --- 
# KeyStore
keytool -genkey -keystore certs/client/client.keystore.jks -validity 365 -storepass $PASSWORD -keypass $PASSWORD -dname "CN=client" -storetype pkcs12

# CSR
openssl req -new -newkey rsa:4096 -subj "/CN=My Company" -nodes -keyout certs/client/cli.key -out certs/client/cli.csr

# CSR Signed with the CA
openssl x509 -req -CA certs/ca/ca-cert -CAkey certs/ca/ca-key -in certs/client/cli.csr -out certs/client/cli-signed.crt -days 365 -CAcreateserial -passin pass:$PASSWORD

# Import CA certificate in KeyStore
keytool -keystore certs/client/client.keystore.jks -alias CARoot -import -file certs/ca/ca-cert -storepass $PASSWORD -keypass $PASSWORD -noprompt

# Import Signed CSR In KeyStore
keytool -keystore certs/client/client.keystore.jks -alias kafkacli -import -file certs/client/cli-signed.crt -storepass $PASSWORD -keypass $PASSWORD -noprompt

# Import CA certificate In TrustStore
keytool -keystore certs/client/client.truststore.jks -alias CARoot -import -file certs/ca/ca-cert -storepass $PASSWORD -keypass $PASSWORD -noprompt

