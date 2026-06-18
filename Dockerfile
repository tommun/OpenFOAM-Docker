# Use Ubuntu 22.04 for better compatibility with OpenFOAM 13 dependencies
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install basic dependencies
RUN apt-get update && apt-get install -y \
    wget \
    lsb-release \
    software-properties-common \
    git \
    ssh \
    rclone \
    sudo \
    bash-completion \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# 2. Install OpenFOAM 13
RUN wget -O - https://dl.openfoam.org/gpg.key | gpg --dearmor > /usr/share/keyrings/openfoam.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/openfoam.gpg] http://dl.openfoam.org/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/openfoam.list \
    && apt-get update && apt-get install -y openfoam13 \
    && rm -rf /var/lib/apt/lists/*

# 3. Create user 'foam'
RUN useradd -m -s /bin/bash foam && \
    echo "foam ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER foam
WORKDIR /home/foam

# 4. Configure environment
RUN echo "source /opt/openfoam13/etc/bashrc" >> ~/.bashrc && \
    echo "alias paraFoam='touch \$(basename \$(pwd)).foam'" >> ~/.bashrc
RUN mkdir -p /home/foam/work /home/foam/gdrive /home/foam/.config/rclone

# 5. Add entrypoint script
COPY --chown=foam:foam entrypoint.sh /home/foam/entrypoint.sh
RUN chmod +x /home/foam/entrypoint.sh

ENTRYPOINT ["/home/foam/entrypoint.sh"]
