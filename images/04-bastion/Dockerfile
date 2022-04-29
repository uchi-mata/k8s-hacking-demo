FROM uchimata/k8sdemo-bastion

COPY config /config
RUN chmod -R 0755 /config; cp /config/authorized_keys /root/.ssh

CMD ["/config/run.sh"]
