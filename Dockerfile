FROM maven:3.8-ibmjava-alpine as backend-builder
WORKDIR /project
RUN apk update && apk add git
RUN git clone https://github.com/LyricSeraph/LyricalGalleryBackend.git
RUN cd LyricalGalleryBackend && mvn package

FROM node:14-alpine as frontend-builder
WORKDIR /project
RUN apk update && apk add git
RUN git clone https://github.com/LyricSeraph/LyricalGalleryFrontend.git
RUN cd LyricalGalleryFrontend && npm install; npm run-script build

FROM openjdk:8-jdk-alpine
RUN apk update && apk add ffmpeg
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
WORKDIR /app
COPY --from=backend-builder /project/LyricalGalleryBackend/target/*.jar app.jar
COPY --from=frontend-builder /project/LyricalGalleryFrontend/dist dist
COPY config.properties config.properties
ENV SPRING_CONFIG_NAME=application,config
ENV SPRING_CONFIG_LOCATION=classpath:/,/app/
EXPOSE 80
CMD ["java", "-jar", "app.jar"]
