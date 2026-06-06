FROM dart:stable AS build
WORKDIR /app
COPY pubspec.yaml ./
RUN dart pub get # <-- Bắt Docker tự tải thư viện để lấy đường dẫn Linux
COPY . .
RUN dart compile exe bin/*.dart -o bin/server