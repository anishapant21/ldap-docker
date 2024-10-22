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
    tcpdump \
    openssl

# SSH Configuration
RUN mkdir /var/run/sshd && \
    echo 'Port 2222' >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'UsePAM yes' >> /etc/ssh/sshd_config

# Create a local user 'mie' with password 'mie' and sudo privileges
RUN useradd -m -s /bin/bash mie && \
    echo 'mie:mie' | chpasswd && \
    echo 'mie ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers.d/mie

# LDAP Configuration
COPY users.ldif /etc/ldap/users.ldif
COPY setup.ldif /etc/ldap/setup.ldif

# Configure LDAP client
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

# Configure LDAP TLS settings
COPY enable-tls.ldif /etc/ldap/enable-tls.ldif

# Set appropriate permissions for LDAP directories
RUN chown -R openldap:openldap /etc/ldap/slapd.d && \
    chmod -R 750 /etc/ldap/slapd.d && \
    chmod 755 /etc/ssl/private && \
    chmod 755 /etc/ssl/certs

# Generate certificates for TLS
RUN openssl req -new -x509 -nodes -out /etc/ssl/certs/ldap-cert.pem -keyout /etc/ssl/private/ldap-key.pem -days 365 \
    -subj "/C=US/ST=IN/L=City/O=MIE/CN=localhost" && \
    cp /etc/ssl/certs/ldap-cert.pem /etc/ssl/certs/ca-cert.pem && \
    chown openldap:openldap /etc/ssl/certs/ldap-cert.pem /etc/ssl/private/ldap-key.pem /etc/ssl/certs/ca-cert.pem && \
    chmod 600 /etc/ssl/private/ldap-key.pem && \
    chmod 644 /etc/ssl/certs/ldap-cert.pem /etc/ssl/certs/ca-cert.pem

# Apply TLS configuration
RUN slapd -h "ldapi:///" -u openldap -g openldap -d 256 & \
    sleep 5 && \
    ldapmodify -H ldapi:/// -Y EXTERNAL -f /etc/ldap/enable-tls.ldif && \
    killall slapd && \
    chmod 640 /etc/ssl/private/ldap-key.pem

# Start services and set permissions
CMD service slapd start && \
    service ssh start && \
    service sssd start && \
    bash
