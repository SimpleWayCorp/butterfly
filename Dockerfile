FROM ubuntu:22.04

RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    openssh-client \
    telnet \
    vim \
    wget \
    python3 \
    python3 \
    python3-pip \
 && pip3 install --no-cache-dir pyOpenSSL \
 && pip3 install --no-cache-dir tornado \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

WORKDIR /opt
ADD . /opt/app
WORKDIR /opt/app

RUN python3 setup.py build \
 && python3 setup.py install

RUN echo /bin/rbash >> /etc/shells \
 && useradd ruser -m -s /bin/rbash \
 && echo "ruser:ruser" | chpasswd \
 && echo "PATH=\$HOME/bin" > /home/ruser/.bashrc \
 && echo "PS1='$ '" >> /home/ruser/.bashrc \
 && echo "HISTSIZE=0" >> /home/ruser/.bashrc \
 && echo "TMOUT=3600" >> /home/ruser/.bashrc \
 && echo "enable -n alias break builtin caller cd command compgen complete compopt declare dirs disown echo enable eval exec export fc getopts hash help history let local logout mapfile popd printf pushd pwd read readarray readonly return shift shopt source suspend test times type typeset ulimit umask unalias unset wait " >> /home/ruser/.bashrc \
 && echo "" > /home/ruser/.bash_logout \
 && chown root:root /home/ruser/.bashrc \
 && chown root:root /home/ruser/.bash_logout \
 && echo "    HostKeyAlgorithms=+ssh-rsa,ssh-dss" >> /etc/ssh/ssh_config \
 && echo "    PubkeyAcceptedAlgorithms=+ssh-rsa,ssh-dss" >> /etc/ssh/ssh_config \
 && echo "    KexAlgorithms=+diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha256" >> /etc/ssh/ssh_config \
 && echo "    Ciphers=+3des-cbc,aes256-cbc,aes192-cbc,aes128-cbc" >> /etc/ssh/ssh_config

RUN sed -i '1iauth sufficient pam_permit.so' /etc/pam.d/common-auth

USER ruser

EXPOSE 57575

CMD ["butterfly.server.py", "--unsecure", "--host=0.0.0.0"]
