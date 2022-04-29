FROM redis


COPY config /config
RUN apt update -y; apt install -y curl openssh-server procps; chmod -R 0755 /config; mkdir -p /root/.ssh

CMD ["/config/run.sh"]
