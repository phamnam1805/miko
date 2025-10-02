# immediately bail if any command fails
set -e

echo "generating CA private key and certificate"
openssl req -nodes -new -x509 -keyout certs/ca-key.pem -out certs/ca-cert.pem -days 65536 -config config/ca.cnf

echo "generating simple-app private key and CSR"
openssl req  -new -nodes -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -keyout certs/simple-app-key.pem -out certs/simple-app.csr -config config/simple-app.cnf

echo "generating simple-app certificate and signing it"
openssl x509 -days 65536 -req -in certs/simple-app.csr -CA certs/ca-cert.pem -CAkey certs/ca-key.pem -CAcreateserial -out certs/simple-app-cert.pem -extensions req_ext -extfile config/simple-app.cnf

echo "verifying generated certificates"
openssl verify -CAfile certs/ca-cert.pem certs/simple-app-cert.pem

echo "exporting simple-app private key to DER format"
openssl pkcs8 -topk8 -inform PEM -outform DER -nocrypt -in certs/simple-app-key.pem -out certs/simple-app-key.der

echo "cleaning up temporary files"
rm certs/simple-app.csr
rm certs/ca-key.pem