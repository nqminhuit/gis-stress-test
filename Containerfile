FROM docker.io/eclipse-temurin:21-jre-alpine
RUN apk add --no-cache wget
WORKDIR /app/gitbucket
RUN wget -q https://github.com/gitbucket/gitbucket/releases/download/4.41.0/gitbucket.war
ENTRYPOINT java -jar gitbucket.war
