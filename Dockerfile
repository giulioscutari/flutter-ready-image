#Stage 1 - Install dependencies and build the app
FROM ubuntu:22.04 AS build-env

# Install flutter dependencies
RUN apt-get update
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3
RUN apt-get clean

# Clone the flutter repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter path
# RUN /usr/local/flutter/bin/flutter doctor -v
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor
# Enable flutter web
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

RUN mkdir /app/
COPY . /app/
WORKDIR /app/flutter_application
RUN flutter pub get && flutter clean && flutter build web --web-renderer html --release --dart-define=SENTRY_DSN=${SENTRY_DSN} --dart-define=PROJECT_URL=${PROJECT_URL}
RUN chown -R 1000:1000 /app/* 
EXPOSE 5000
USER 1000
CMD ["/app/scripts/run-server.sh"]
