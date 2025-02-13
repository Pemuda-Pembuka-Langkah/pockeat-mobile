FROM debian:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl git wget unzip libgconf-2-4 gdb libstdc++6 \
    libglu1-mesa fonts-droid-fallback lib32stdc++6 python3

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Get dependencies first (for better caching)
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

# Build app
COPY . .
RUN flutter build web

WORKDIR /app/build/web
CMD python3 -m http.server 8080