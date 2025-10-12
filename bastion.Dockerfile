FROM debian:12.12-slim

RUN set -eux \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  openssh-server sudo net-tools iproute2 dnsutils iputils-ping traceroute \
  tcpdump nmap telnet netcat-openbsd htop iotop lsof strace procps jq vim \
  less grep curl wget tree file unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash snowflake \
  && echo "snowflake ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/snowflake \
  && chmod 0440 /etc/sudoers.d/snowflake \
  && mkdir -p /home/snowflake/.ssh \
  && chown -R snowflake:snowflake /home/snowflake/.ssh

COPY authorized_keys /home/snowflake/.ssh/authorized_keys

RUN chown snowflake:snowflake /home/snowflake/.ssh/authorized_keys \
  && chmod 700 /home/snowflake/.ssh \
  && chmod 600 /home/snowflake/.ssh/authorized_keys

RUN mkdir /var/run/sshd

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
