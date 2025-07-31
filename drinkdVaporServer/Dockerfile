# drinkdVaporServer/Dockerfile - for docker-compose
# ================================
# Build image
# ================================
FROM swift:6.1-noble AS build
# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev
# Set up a build area
WORKDIR /build
# Copy shared models
COPY drinkdSharedModels /drinkdSharedModels
# Copy package files
COPY drinkdVaporServer/Package.* ./
RUN swift package resolve \
        $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)
# Copy entire app
COPY drinkdVaporServer/ .
# Build the application
RUN swift build -c release \
        --product drinkdVaporServer \
        --static-swift-stdlib \
        -Xlinker -ljemalloc
# Switch to the staging area
WORKDIR /staging
# Copy main executable to staging area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/drinkdVaporServer" ./
# Copy static swift backtracer binary to staging area
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./
# Copy resources bundled by SPM to staging area
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;
# Copy any resources from the public directory and views directory if the directories exist
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true
# ================================
# Run image
# ================================
FROM ubuntu:noble
# Install runtime dependencies
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
      libjemalloc2 \
      ca-certificates \
      tzdata \
      libcurl4 \
    && rm -r /var/lib/apt/lists/*
# Create vapor user
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor
# Switch to the new home directory
WORKDIR /app
# Copy built executable and any staged resources from builder
COPY --from=build --chown=vapor:vapor /staging /app
# Environment configuration
ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static
# Run as vapor user
USER vapor:vapor
# Expose port
EXPOSE 8080
# Start the service
ENTRYPOINT ["./drinkdVaporServer"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]