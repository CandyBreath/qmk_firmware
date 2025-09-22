FROM ubuntu:24.04

# UID from central login system can be very big.
RUN sed -i 's/^UID_MAX.*/UID_MAX 2000000000/' /etc/login.defs

# Create user and group.
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
&& useradd -s /bin/bash --uid $USER_UID --gid $USER_GID --create-home --no-log-init $USERNAME \
&& mkdir /home/$USERNAME/.config \
&& chown $USER_UID:$USER_GID /home/$USERNAME/.config

# Enable sudo inside container
RUN apt-get update \
&&  apt-get install -y sudo \
&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
&& chmod 0440 /etc/sudoers.d/$USERNAME \
&& rm -rf /var/lib/apt/lists/*

# Set environment variables to avoid user prompts during install
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    QMK_HOME=/qmk_environment

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-pip \
    python3-venv \
    python3-setuptools \
    gcc \
    unzip \
    wget \
    zip \
    dfu-programmer \
    dfu-util \
    avr-libc \
    binutils-arm-none-eabi \
    gcc-arm-none-eabi \
    binutils-avr \
    gcc-avr \
    libnewlib-arm-none-eabi \
    libusb-1.0-0-dev \
    make \
    util-linux \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create and activate Python virtual environment for QMK tooling
RUN python3 -m venv /qmk_venv
ENV PATH="/qmk_venv/bin:$PATH"

# Install QMK CLI
RUN pip install --no-cache-dir qmk

# Ensure qmk_environment exists at runtime
VOLUME ["/qmk_environment"]
WORKDIR /qmk_environment

# Set up udev rules (optional, useful if doing flashing from container)
# COPY ./rules.d/ /etc/udev/rules.d/
# RUN udevadm control --reload-rules && udevadm trigger

USER ${USERNAME}

# Default to an interactive shell
CMD [ "bash" ]
