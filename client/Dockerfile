FROM debian:latest

# Copy environment variables
COPY ldap_env.sh /tmp/ldap_env.sh
RUN chmod +x /tmp/ldap_env.sh && . /tmp/ldap_env.sh

# Install necessary packages
RUN apt-get update && apt-get install -y \
    ldap-utils \
    openssh-client \
    openssh-server \
    sssd \
    sssd-ldap \
    sudo \
    libnss-ldap \
    libpam-ldap \
    ca-certificates \
    vim \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# SSH Configuration
RUN mkdir /var/run/sshd && \
    echo "Port 22" >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'UsePAM yes' >> /etc/ssh/sshd_config

# Configure LDAP client
RUN . /tmp/ldap_env.sh && \
    echo "BASE    $LDAP_BASE" > /etc/ldap/ldap.conf && \
    echo "URI     $LDAP_URI" >> /etc/ldap/ldap.conf && \
    echo "BINDDN  $LDAP_ADMIN_DN" >> /etc/ldap/ldap.conf && \
    echo "TLS_REQCERT allow" >> /etc/ldap/ldap.conf

COPY sssd.conf /etc/sssd/sssd.conf
COPY ca-cert.pem /etc/ssl/certs/ca-cert.pem
RUN  chmod 644 /etc/ssl/certs/ca-cert.pem

# Configure SSSD
RUN chmod 600 /etc/sssd/sssd.conf && \
    chmod 755 /etc/ssl/certs 

# Startup to keep container running
CMD service sssd start && \
    update-ca-certificates && \
    tail -f /dev/null