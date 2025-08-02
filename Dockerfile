# Dockerfile for IceStick FPGA development environment
# This creates the alpha-nerds-icestick-env Docker image with all necessary tools

FROM ubuntu:20.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    bison \
    flex \
    libreadline-dev \
    gawk \
    tcl-dev \
    libffi-dev \
    git \
    graphviz \
    xdot \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    libboost-system-dev \
    libboost-python-dev \
    libboost-filesystem-dev \
    zlib1g-dev \
    cmake \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /tools

# Install IceStorm tools
RUN git clone https://github.com/YosysHQ/icestorm.git icestorm && \
    cd icestorm && \
    make -j$(nproc) && \
    make install

# Install Yosys
RUN git clone https://github.com/YosysHQ/yosys.git yosys && \
    cd yosys && \
    make -j$(nproc) && \
    make install

# Install nextpnr
RUN git clone https://github.com/YosysHQ/nextpnr nextpnr && \
    cd nextpnr && \
    cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local . && \
    make -j$(nproc) && \
    make install

# Install GHDL
RUN git clone https://github.com/ghdl/ghdl.git ghdl && \
    cd ghdl && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# Install GHDL Yosys plugin
RUN git clone https://github.com/ghdl/ghdl-yosys-plugin.git ghdl-yosys-plugin && \
    cd ghdl-yosys-plugin && \
    make -j$(nproc) && \
    make install

# Set PATH
ENV PATH="/usr/local/bin:${PATH}"

# Set working directory for projects
WORKDIR /wrk

# Default command
CMD ["/bin/bash"]
