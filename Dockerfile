ARG BUILDER_IMAGE=maven
ARG RUNTIME_IMAGE=gcr.io/distroless/java17-debian11
FROM $BUILDER_IMAGE AS build
ADD . .
RUN unset MAVEN_CONFIG && ./mvnw clean package -B -DskipTests
FROM $RUNTIME_IMAGE AS runtime
COPY --from=build /target/demo-0.0.1-SNAPSHOT.jar /demo.jar 
COPY ./elastic-apm-agent-1.38.1-20230512.153148-12.jar /var/tmp/elastic-apm-agent-1.12.0.jar
ENTRYPOINT java -javaagent:/var/tmp/elastic-apm-agent-1.12.0.jar -Delastic.apm.service_name=apm-demo-service -Delastic.apm.server_url=http://apmserver:8200 -Delastic.apm.application_packages=com.myapp -Delastic.apm.hostname=myhost -server -Djava.security.egd=file:/dev/./urandom -jar /demo.jar