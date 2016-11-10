# This dockerfile instals the logtrail and elasticsense plugin
FROM kibana:4.6.2

RUN apt-get update && apt-get install -y netcat

COPY entrypoint.sh /tmp/entrypoint.sh
RUN chmod +x /tmp/entrypoint.sh

RUN kibana plugin --install elastic/sense
RUN kibana plugin -i logtrail -u https://github.com/sivasamyk/logtrail/releases/download/0.1.4/logtrail-4.x-0.1.4.tar.gz
COPY logtrail.json /opt/kibana/installedPlugins/logtrail/logtrail.json

CMD ["/tmp/entrypoint.sh"]
