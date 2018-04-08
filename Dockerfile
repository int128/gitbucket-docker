FROM openjdk:8-jdk-alpine AS builder

ENV SBT_VERSION 1.1.2
RUN apk add --no-cache curl bash unzip && \
    curl -fL -o /sbt.tgz "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" && \
    tar -xf /sbt.tgz && \
    chmod +x /sbt/bin/sbt && \
    /sbt/bin/sbt sbtVersion

ENV GITBUCKET_BRANCH master
ADD https://github.com/gitbucket/gitbucket/archive/${GITBUCKET_BRANCH}.zip /${GITBUCKET_BRANCH}.zip
RUN unzip /${GITBUCKET_BRANCH}.zip && \
    cd /gitbucket-${GITBUCKET_BRANCH} && \
    /sbt/bin/sbt executable && \
    mv -v target/executable/gitbucket.war /

FROM openjdk:8-jdk-alpine

# ttf-dejavu: Fix NPE on font rendering https://github.com/docker-library/openjdk/issues/73
RUN apk add --no-cache git curl bash ttf-dejavu

ENV GITBUCKET_HOME /var/gitbucket

RUN addgroup -g 1000 gitbucket && \
    adduser -h "$GITBUCKET_HOME" -u 1000 -G gitbucket -s /bin/bash -D gitbucket && \
    mkdir -p /usr/share/gitbucket

VOLUME /var/gitbucket

COPY --from=builder /gitbucket.war /usr/share/gitbucket/gitbucket.war

COPY gitbucket.sh /usr/share/gitbucket/gitbucket.sh
RUN chmod +x /usr/share/gitbucket/gitbucket.sh

# Port for web service
EXPOSE 8080
# Port for SSH access to git repository (Optional)
EXPOSE 29418

# Run as dedicated user
USER gitbucket

# Configure heap memory by cgroup memory limit
# https://blogs.oracle.com/java-platform-group/java-se-support-for-docker-cpu-and-memory-limits
ENV JAVA_OPTS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap

CMD ["/usr/share/gitbucket/gitbucket.sh"]
