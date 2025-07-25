FROM swift:6.1-jammy

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-11-jre-headless \
    wget \
    curl \
    libgd-dev \
    libgd3 \
    && rm -rf /var/lib/apt/lists/*

ENV HADOOP_VERSION=3.4.0
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

RUN wget -qO- https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | \
    tar -xz -C /opt && \
    ln -s /opt/hadoop-${HADOOP_VERSION} /opt/hadoop && \
    mkdir -p $HADOOP_HOME/logs

WORKDIR /app

COPY Core ./Core
COPY Examples ./Examples
COPY docker/entrypoint.sh ./docker/entrypoint.sh

RUN chmod +x ./docker/entrypoint.sh

RUN cd Core && swift build -c release
RUN cd Examples/PhotoDupes && swift build -c release
RUN cd Examples/WordCount && swift build -c release

ENV PATH="/app/Core/.build/release:/app/Examples/PhotoDupes/.build/release:/app/Examples/WordCount/.build/release:$PATH"

ENTRYPOINT ["/app/docker/entrypoint.sh"]