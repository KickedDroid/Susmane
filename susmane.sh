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
RUN apk add --no-cache curl wget file
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
podman run -it --rm -v --network none malware-analysis /bin/sh -c "
    wget '$URL' -O /analysis/suspicious-file
    echo 'File downloaded. Perform your analysis now.'
    /bin/sh
"

echo "Container session ended. Check the 'analysis' directory for any files you saved."
