FROM dart:stable AS build
WORKDIR /app
COPY pubspec.yaml ./
RUN dart pub get
COPY . .
RUN dart compile exe bin/backend_api.dart -o bin/server
EXPOSE 8080
CMD ["/app/bin/server"]