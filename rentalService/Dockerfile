
FROM amazoncorretto:17 AS install
WORKDIR /build
COPY . .
RUN ./gradlew build


FROM amazoncorretto:17 AS release
VOLUME /TMP
EXPOSE 8080
COPY --from=install /build/build/libs/*.jar app.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]