# ================================
# Build image
# ================================
FROM swiftlang/swift:nightly-focal as build

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# Copy all source files
COPY . .

# Build everything, with optimizations
RUN swift build

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build --show-bin-path)/lifx" ./

# Copy resources from the resources directory if the directories exist
# Ensure that by default, neither the directory nor any of its contents are writable.
RUN [ -d "$(swift build --package-path /build/WebService --show-bin-path)/WebService_WebService.resources" ] \
    && mv "$(swift build --package-path /build/WebService --show-bin-path)/WebService_WebService.resources" ./ \
    && chmod -R a-w ./WebService_WebService.resources \
    || echo No resources to copy

# ================================
# Run image
# ================================
FROM swiftlang/swift:nightly-focal as run

# Make sure all system packages are up to date.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -r /var/lib/apt/lists/*

# Create a apodini user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app lifx

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=build --chown=lifx:lifx /staging /app

# Ensure all further commands run as the lifx user
USER lifx:lifx

# Start the Apodini service when the image is run.
# The default port is 80. Can be adapted using the `--port` argument
ENTRYPOINT ["./lifx"]