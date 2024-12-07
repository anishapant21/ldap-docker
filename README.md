# LDAP & SSSD Docker Container

This repository provides a Dockerized environment that includes:
- **OpenLDAP** (`slapd`) for user directory management
- **SSSD** (System Security Services Daemon) for integrating LDAP authentication
- **OpenSSH** for remote login access
- A local user (`mie`) and LDAP-based authentication for users.

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
- Setting up OpenSSH on port `2222`
- Configuring LDAP with a base domain `dc=mieweb,dc=com`
- Adding a local user `mie` with password authentication and root access without a password
- Pre-configuring `slapd` for LDAP directory setup
- Adding LDAP users using LDIF files
- Configuring and running `SSSD` for LDAP authentication.

## How to Build and Run

### Step 1: Build the Docker Image

To build the Docker image, navigate to the directory with your Dockerfile and run the following command:

```bash
docker build -t myldap-sssd .
```

### Step 2: Run the Docker Container

Start the Docker container with the following command, which binds the SSH port (`2222`) to your local machine:

```bash
docker run -it -p 2222:22 myldap-sssd bash
```

### Step 3: Start Required Services

Once inside the container, you need to start the following services manually:

```bash
service ssh start
service slapd start
sssd -i
```

### Step 4: Test User Existence and SSH into the Container

Before SSHing into the running container, you can verify the existence of a user using the LDAP search command.

#### Test the existence of the LDAP user (`ann`):

```bash
ldapsearch -x -H ldap://localhost -b "dc=mieweb,dc=com" "(uid=ann)"
```

### Step 5: SSH into the Container

You can now SSH into the running container using either the local `mie` user or an LDAP user.

#### For the local user (`mie`):

```bash
ssh mie@localhost -p 2222
Password: mie
```

#### For the ldap user (`ann`):

```bash
ssh ann@localhost -p 2222
Password: ann
```

### Step 5: Access Logs

Once you are logged in, you will be able to view the logs of the running services. This can be helpful for monitoring and troubleshooting. 

