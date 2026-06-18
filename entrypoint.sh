#!/bin/bash
set -e

# Load OpenFOAM environment
source /opt/openfoam13/etc/bashrc

echo "OpenFOAM 13 Environment is ready."
echo "Use 'docker exec -it openfoam13-container bash' to enter the container."

# Keep container running
tail -f /dev/null
