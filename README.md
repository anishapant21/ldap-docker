# OpenLDAP Server

This project provides a containerized OpenLDAP server setup for user directory management and authentication. It includes OpenLDAP (`slapd`) for handling directory services, SSSD for integrating LDAP authentication, and OpenSSH for remote access.

This repository provides a Dockerized environment that includes:

- **OpenLDAP** (`slapd`) for user directory management
- **SSSD** (System Security Services Daemon) for integrating LDAP authentication
- **OpenSSH** for remote login access
- LDAP-based authentication for users (`ann`, `chris`, `hrits`).

## Prerequisites

- Docker installed on your machine
- Basic knowledge of Docker containers

## Dockerfile Overview

The Dockerfile is based on the `debian:latest` image and installs the following packages:

- `slapd` (OpenLDAP)
- `sssd` and `sssd-ldap` (for handling LDAP authentication)
- `openssh-server` (to allow SSH connections)
- Various utilities (`vim`, `net-tools`, etc.) for convenience

### Configuration Steps

- Setting up the OpenLDAP server on port `389`
- Configuring LDAP with the base domain `dc=mieweb,dc=com`
- Adding a local user `mie` with password authentication and root access without a password
- Pre-configuring `slapd` for LDAP directory setup
- Adding LDAP users using LDIF files
- Configuring and running `SSSD` for LDAP authentication

## How to Build and Run OpenLDAP Server

### Step 1: Build the Docker Image

To build the Docker image, navigate to the directory with your Dockerfile and run the following command:

```bash
cd server
docker build -t openldap-server .
```

### Step 2: Run the Docker Container

Start the Docker container with the following command, which binds port `389` to your local machine:

```bash
docker run -it -p 389:389 openldap-server bash
```

### Step 3: Ensure the `slapd` Service is Running

Check the status of `slapd` with:

```bash
service slapd status
```

If it is not running, start it manually:

```bash
service slapd start
```

### Step 4: Verify LDAP User Existence

Before attempting to SSH into a client using this LDAP server, verify that the user exists in the directory.

#### Test the existence of LDAP user (`ann`):

```bash
ldapsearch -x -H ldap://localhost:389 -b "dc=mieweb,dc=com" "(uid=ann)"
```

### Step 5: SSH into the Client (Using This LDAP Server)

Once the client machine is properly configured to use this LDAP server, you can SSH into it using an LDAP user.

#### SSH into the client as user `ann`:

```bash
ssh ann@client-machine -p 2222
Password: ann
```

> **Note:** This will only work on a client that is configured to use this OpenLDAP server for authentication. Running it inside the container or on an unconfigured system will not work.

