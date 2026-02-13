ARG BASE_IMAGE=mtgo-runtime
FROM ${BASE_IMAGE}

USER root

# Install .NET SDK 10.0 (Preview) to Linux environment
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
    && chmod +x ./dotnet-install.sh \
    && ./dotnet-install.sh --channel 10.0 --quality preview --install-dir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet-install.sh

# Update dotnet workload
RUN dotnet workload config --update-mode workload-set \
    && dotnet workload update

# Create global wine-run command
# This delegates to the script in the workspace
# Copy scripts into the image
COPY scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*.sh

# Create the wine-run wrapper
RUN echo '#!/bin/bash\n/opt/scripts/wine-run.sh "$@"' > /usr/local/bin/wine-run \
    && chmod +x /usr/local/bin/wine-run

USER wine
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/xvfb-entrypoint.sh", "/opt/scripts/entrypoint.sh"]
CMD ["/bin/bash"]
