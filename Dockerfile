# Dockerfile for Fly.io deployment (in parent directory)
FROM swift:6.1-noble AS build

# Remove this problematic line:
# RUN apt-get update && apt-get install -y package && rm -rf /var/lib/apt/lists/*

# Keep this one - it installs the real dependencies
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy shared models (correct path from parent directory)
COPY drinkdSharedModels /drinkdSharedModels

# Copy package files (correct path from parent directory)
COPY drinkdVaporServer/Package.* ./
RUN swift package resolve

# Copy app source (correct path from parent directory)
COPY drinkdVaporServer/Sources ./Sources

# Copy tests explicitly
COPY drinkdVaporServer/Tests ./Tests

# Build
RUN swift build -c release --product drinkdVaporServer --static-swift-stdlib -Xlinker -ljemalloc

# Switch to staging
WORKDIR /staging
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/drinkdVaporServer" ./
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./

# Copy resources if they exist
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \; || true
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

# Runtime image
FROM ubuntu:noble
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
      libjemalloc2 \
      ca-certificates \
      tzdata \
      libcurl4 \
    && rm -r /var/lib/apt/lists/*

RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

WORKDIR /app
COPY --from=build --chown=vapor:vapor /staging /app

ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

USER vapor:vapor
EXPOSE 8080
ENTRYPOINT ["./drinkdVaporServer"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]