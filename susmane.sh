#!/bin/bash

# Check if a URL is provided
if [ $# -eq 0 ]; then
    echo "Please provide a URL as an argument."
    echo "Usage: $0 <url>"
    exit 1
fi

URL=$1

# Create Dockerfile if it doesn't exist
if [ ! -f Dockerfile ]; then
    cat << EOF > Dockerfile
FROM alpine:latest
RUN apk add --no-cache curl wget
WORKDIR /analysis
EOF
    echo "Dockerfile created."
fi

# Build the container image if it doesn't exist
if ! podman image exists malware-analysis; then
    podman build -t malware-analysis .
    echo "Container image built."
fi

# Create analysis directory if it doesn't exist
mkdir -p analysis

# Run the container
podman run -it --rm -v ./analysis:/mnt/host malware-analysis /bin/sh -c "
    wget '$URL' -O /analysis/suspicious-file
    echo 'File downloaded. Perform your analysis now.'
    echo 'If the file is safe, you can copy it to the host system with:'
    echo 'cp /analysis/suspicious-file /mnt/host/'
    /bin/sh
"

echo "Container session ended. Check the 'analysis' directory for any files you saved."
