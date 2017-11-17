FROM easypi/alpine-arm

LABEL maintainer "https://github.com/ISNIT0"

ENV KAFKA_VERSION 1.0.0
ENV SCALA_VERSION 2.12
ENV LANG C.UTF-8

# see https://github.com/docker-library/openjdk/blob/b4f29ba829765552239bd18f272fcdaf09eca259/8-jdk/alpine/Dockerfile

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u131
ENV JAVA_ALPINE_VERSION 8.131.11-r2

RUN set -x \
	&& apk add --no-cache \
		openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]



LABEL name="kafka" version=${KAFKA_VERSION}

RUN apk add --no-cache openjdk8-jre bash docker coreutils su-exec
RUN apk add --no-cache -t .build-deps curl ca-certificates jq \
  && mkdir -p /opt \
	&& mirror=$(curl --stderr /dev/null https://www.apache.org/dyn/closer.cgi\?as_json\=1 | jq -r '.preferred') \
	&& curl -sSL "${mirror}kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
		| tar -xzf - -C /opt \
	&& mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka \
  && adduser -DH -s /sbin/nologin kafka \
  && chown -R kafka: /opt/kafka \
  && rm -rf /tmp/* \
  && apk del --purge .build-deps

ENV PATH /sbin:/opt/kafka/bin/:$PATH

WORKDIR /opt/kafka

VOLUME ["/tmp/kafka-logs"]

EXPOSE 9092 2181

# COPY config/log4j.properties /opt/kafka/config/
COPY config/server.properties /opt/kafka/config/
COPY config/zookeeper.properties /opt/kafka/config/
COPY kafka-entrypoint.sh /kafka-entrypoint.sh
COPY scripts /

ENTRYPOINT ["/kafka-entrypoint.sh"]
CMD ["kafka-server-start.sh", "config/server.properties"]

# HEALTHCHECK --interval=5s --timeout=2s --retries=5 CMD bin/health.sh
