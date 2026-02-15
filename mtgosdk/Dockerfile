ARG BASE_IMAGE=mtgo-runtime
FROM ${BASE_IMAGE}

USER root

# Install .NET SDK 10.0 (Preview) to Linux and Wine environments
RUN wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --channel 10.0 --quality preview --install-dir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && wget https://builds.dotnet.microsoft.com/dotnet/Sdk/10.0.100-rc.2.25502.107/dotnet-sdk-10.0.100-rc.2.25502.107-win-x64.zip -O /tmp/dotnet-win.zip \
    && mkdir -p /home/wine/.wine/drive_c/dotnet \
    && unzip /tmp/dotnet-win.zip -d /home/wine/.wine/drive_c/dotnet \
    && chown -R wine:wine /home/wine/.wine/drive_c/dotnet \
    && rm /tmp/dotnet-install.sh /tmp/dotnet-win.zip

# Update dotnet workload
RUN dotnet workload config --update-mode workload-set \
    && dotnet workload update

# Create global wine-run command
# This delegates to the script in the workspace
# Copy scripts into the image
COPY scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*.sh

# Create the wine-run and wine-shell wrappers
RUN echo '#!/bin/bash\n/opt/scripts/wine-run.sh "$@"' > /usr/local/bin/wine-run \
    && echo '#!/bin/bash\n/opt/scripts/wine-shell.sh "$@"' > /usr/local/bin/wine-shell \
    && chmod +x /usr/local/bin/wine-run /usr/local/bin/wine-shell

USER wine
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/xvfb-entrypoint.sh", "/opt/scripts/entrypoint.sh"]
CMD ["/bin/bash"]
