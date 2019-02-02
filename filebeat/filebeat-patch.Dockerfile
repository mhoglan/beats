ARG FILEBEAT_VERSION=6.7.1
FROM docker.elastic.co/beats/filebeat:$FILEBEAT_VERSION

COPY filebeat /usr/share/filebeat/filebeat
