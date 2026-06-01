#!/bin/bash
set -e

# Start VNC server
vncserver :1 -geometry 1280x800 -depth 24

# Start websockify for noVNC
/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 6080 &

echo "noVNC is running at http://localhost:6080/vnc.html"
echo "VNC Password is: foam123"

# Keep container running
tail -f /dev/null
