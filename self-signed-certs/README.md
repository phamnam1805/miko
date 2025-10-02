# Self-Signed Certificates Generator

This directory contains scripts and configuration files for generating self-signed certificates for development and testing purposes.

## Overview

This toolkit provides:
- **Certificate generation script** (`generate-certs.sh`) - Automated script to create CA, server, and client certificates
- **Configuration templates** (`config/` directory) - OpenSSL configuration files for different certificate types

## Files Structure

```
self-signed-certs/
├── generate-certs.sh          # Main certificate generation script
├── config/
│   ├── ca.cnf                 # CA (Certificate Authority) configuration
│   ├── server.cnf             # Server certificate configuration
│   └── client.cnf             # Client certificate configuration
└── README.md                  # This file
```

## Usage

### Prerequisites

- OpenSSL installed on your system
- Bash shell environment

### Generate Certificates

1. Make the script executable:
```bash
chmod +x generate-certs.sh
```

2. Run the certificate generation script:
```bash
./generate-certs.sh
```

### Generated Certificates

The script will create the following certificates in the `../ssl/` directory:

- **CA Certificates:**
  - `ca-key.pem` - CA private key
  - `ca-cert.pem` - CA certificate

- **Server Certificates:**
  - `server-key.pem` - Server private key
  - `server-cert.pem` - Server certificate
  - `server.csr` - Server certificate signing request

- **Client Certificates:**
  - `client-key.pem` - Client private key
  - `client-cert.pem` - Client certificate
  - `client.csr` - Client certificate signing request

## Configuration Files

### CA Configuration (`config/ca.cnf`)
Defines the Certificate Authority settings including:
- Key size and algorithm
- Distinguished name (DN) information
- Certificate extensions

### Server Configuration (`config/server.cnf`)
Configures server certificates with:
- Server-specific extensions
- Subject Alternative Names (SAN)
- Key usage restrictions

### Client Configuration (`config/client.cnf`)
Configures client certificates with:
- Client authentication extensions
- Key usage for client operations
- Distinguished name settings

## Security Features

- Uses **secp384r1** elliptic curve for enhanced security
- Compatible with s2n-tls security policies
- Certificates valid for 65536 days (for development only)
- Proper certificate extensions for server and client authentication

## Important Notes

⚠️ **For Development Only**: These self-signed certificates are intended for development and testing environments only. Do not use in production.

⚠️ **Trust Issues**: Browsers and clients will show security warnings for self-signed certificates. You may need to manually trust the CA certificate.

⚠️ **Key Management**: Keep private keys secure and never commit them to version control.

## Customization

To customize the certificates:

1. Edit the `OUTPUT_DIR` variable in `generate-certs.sh` to set the desired directory for certificate output
2. Edit the configuration files in the `config/` directory
3. Modify distinguished names, SANs, or certificate extensions
4. Re-run the generation script

## Troubleshooting

- Ensure OpenSSL is installed: `openssl version`
- Check file permissions for the script
- Review OpenSSL error messages for configuration issues
