FROM panard/wine:11.2-wow64

USER root

# Install basic dependencies and headless tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    curl \
    git \
    gnupg \
    xvfb \
    x11vnc \
    procps \
    net-tools \
    x11-utils \
    unzip \
    p7zip-full \
    && rm -rf /var/lib/apt/lists/*

# Fix X11 socket permissions for non-root users
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Create wine user
ENV WINE_USER wine
ENV WINE_UID 1000
RUN useradd -u $WINE_UID -d /home/wine -m -s /bin/bash $WINE_USER

# Switch back to wine user for wine operations
USER wine
ENV WINEPREFIX=/home/wine/.wine
ENV WINEARCH=win64
ENV WINEDEBUG=-all
ENV DOTNET_ROOT=C:\\dotnet
WORKDIR /home/wine

# Copy scripts
USER root
COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh \
    && ln -s /usr/local/bin/mtgo.sh /usr/local/bin/mtgo
USER wine

# Initialize Wine and install dependencies
# We need dotnet48 for MTGO, and corefonts/gdiplus for UI/rendering
RUN wineboot --init \
    && winetricks -q dotnet48 corefonts calibri tahoma consolas lucida win7 gdiplus renderer=gdi \
    && rm -rf /home/wine/.cache/winetricks

# Set up workspace directory
USER root
RUN mkdir -p /workspace && chown wine:wine /workspace
USER wine
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/xvfb-entrypoint.sh"]
CMD ["/bin/bash"]
