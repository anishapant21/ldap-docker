# OpenLDAP Server

This repository provides a Dockerized environment that includes:
- **OpenLDAP** (`slapd`) for user directory management
- **SSSD** (System Security Services Daemon) for integrating LDAP authentication
- **OpenSSH** for remote login access
- A local user (`mie`) and LDAP-based authentication for users(ann, chris, hrits).

## Prerequisites

- Docker installed on your machine
- Basic knowledge of how Docker containers work

## Dockerfile Overview

The Dockerfile is based on the `debian:latest` image and installs the following packages:
- `slapd` (OpenLDAP)
- `sssd` and `sssd-ldap` (for handling LDAP authentication)
- `openssh-server` (to allow SSH connections)
- Various utilities (`vim`, `net-tools`, etc.) for convenience.

The configuration steps include:
- Setting up OpenLDAP server on port `389`
- Configuring LDAP with a base domain `dc=mieweb,dc=com`
- Adding a local user `mie` with password authentication and root access without a password
- Pre-configuring `slapd` for LDAP directory setup
- Adding LDAP users using LDIF files
- Configuring and running `SSSD` for LDAP authentication.

## How to Build and Run OpenLDAP Server

### Step 1: Build the Docker Image

To build the Docker image, navigate to the directory with your Dockerfile and run the following command:

```bash
cd server
docker build -t openldap-server .
```

### Step 2: Run the Docker Container

Start the Docker container with the following command, which binds the port (`389`) to your local machine:

```bash
docker run -it -p 389:389 openldap-server bash
```

### Step 3: Test User Existence and SSH into the Container

Before SSHing into the client using this server, you can verify the existence of a user using the LDAP search command.

#### Test the existence of the LDAP user (`ann`):

```bash
ldapsearch -x -H ldap://localhost:389 -b "dc=mieweb,dc=com" "(uid=ann)"
```

### Step 4: SSH into the Client

You can now SSH into the client using LDAP user(ann).

#### For the ldap user (`ann`):

```bash
ssh ann@localhost -p 2222
Password: ann
```

