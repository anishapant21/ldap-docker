# Use an official Debian base image
FROM debian:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    slapd \
    ldap-utils \
    openssh-server \
    sssd \
    sssd-ldap \
    sudo \
    vim \
    net-tools \
    procps \
    traceroute \
    tcpdump

# SSH Configuration
RUN mkdir /var/run/sshd
# Use port 2222 for SSH
RUN echo 'Port 2222' >> /etc/ssh/sshd_config
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN echo 'UsePAM yes' >> /etc/ssh/sshd_config

# Create local user mie with password 'mie'
RUN useradd -m -s /bin/bash mie && \
    echo 'mie:mie' | chpasswd && \
    echo 'mie ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers.d/mie

# LDAP Configuration
COPY users.ldif /etc/ldap/users.ldif
COPY setup.ldif /etc/ldap/setup.ldif

# Add default LDAP client config
RUN echo "BASE    dc=mieweb,dc=com" > /etc/ldap/ldap.conf && \
    echo "URI     ldap://localhost" >> /etc/ldap/ldap.conf && \
    echo "BINDDN  cn=admin,dc=mieweb,dc=com" >> /etc/ldap/ldap.conf && \
    echo "TLS_REQCERT allow" >> /etc/ldap/ldap.conf

# Set environment variables for LDAP
ENV DEBIAN_FRONTEND=noninteractive

# Pre-configure the slapd package
RUN echo "slapd slapd/internal/generated_adminpw password secret" | debconf-set-selections && \
    echo "slapd slapd/internal/adminpw password secret" | debconf-set-selections && \
    echo "slapd slapd/password2 password secret" | debconf-set-selections && \
    echo "slapd slapd/password1 password secret" | debconf-set-selections && \
    echo "slapd slapd/domain string mieweb.com" | debconf-set-selections && \
    echo "slapd shared/organization string MIE" | debconf-set-selections && \
    dpkg-reconfigure -f noninteractive slapd

# Add LDAP users via LDIF files
RUN slapadd < /etc/ldap/users.ldif

# Configure SSSD
COPY sssd.conf /etc/sssd/sssd.conf
RUN chmod 600 /etc/sssd/sssd.conf

# Start services and set permissions
CMD service slapd start && \
    service ssh start && \
    service sssd start && \
    bash
