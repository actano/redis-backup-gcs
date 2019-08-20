FROM redis:5.0.5

RUN apt-get update && apt-get install -y curl python2.7
# Install google cloud sdk (gcloud and gsutil used in backup.sh)
RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin

RUN mkdir /backup
RUN mkdir /scripts

ADD backup.sh /scripts/backup.sh
RUN chmod +x /scripts/backup.sh

CMD ["/scripts/backup.sh"]
