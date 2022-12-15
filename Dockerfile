FROM ubuntu:22.04

RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    openssh-client \
    telnet \
    vim \
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
 && echo "PATH=\$HOME/bin" > /home/ruser/.bash_profile \
 && echo "PATH=\$HOME/bin" > /home/ruser/.bashrc \
 && echo "PS1='$ '" >> /home/ruser/.bash_profile \
 && echo "PS1='$ '" >> /home/ruser/.bashrc \
 && chown root:root /home/ruser/.bash_profile \
 && chown root:root /home/ruser/.bashrc \
 && mkdir /home/ruser/bin \
 && ln -s /bin/ssh /home/ruser/bin/ \
 && ln -s /bin/telnet /home/ruser/bin/ \
 && ln -s /bin/cat /home/ruser/bin/ \
 && chown -R root:root /home/ruser/bin

RUN sed -i '1iauth sufficient pam_permit.so' /etc/pam.d/common-auth

USER ruser

EXPOSE 57575

CMD ["butterfly.server.py", "--unsecure", "--host=0.0.0.0"]
