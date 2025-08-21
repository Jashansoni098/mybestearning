# Flutter APK Build Container
FROM cirrusci/flutter:stable

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Get dependencies
RUN flutter pub get

# Build APK
RUN flutter build apk --debug

# Copy APK to output directory
RUN mkdir -p /output && cp build/app/outputs/flutter-apk/app-debug.apk /output/

# Set output volume
VOLUME /output

CMD ["echo", "APK built successfully! Check /output/app-debug.apk"]
