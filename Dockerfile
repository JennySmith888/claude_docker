FROM node:24-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates dumb-init \
    bash grep findutils coreutils \
    ripgrep python3 python3-pip \
    libxml2-utils \
    poppler-utils \
    imagemagick ghostscript \
    octave octave-signal octave-control \
    ghdl \
    iverilog \
    yosys \
    verilator \
    ngspice \
    graphviz \
    && pip install --no-cache-dir --break-system-packages \
    flake8 numpy scipy matplotlib oct2py \
    PySpice schemdraw control \
    && rm -rf /var/lib/apt/lists/*

ENV SHELL=/bin/bash

RUN npm install -g @anthropic-ai/claude-code

COPY managed-settings.json /etc/claude-code/managed-settings.json
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && chmod 444 /etc/claude-code/managed-settings.json \
    && mkdir -p /home/node/.claude \
    && chown -R node:node /home/node

USER node
WORKDIR /workspace

ENTRYPOINT ["dumb-init", "--", "entrypoint.sh"]