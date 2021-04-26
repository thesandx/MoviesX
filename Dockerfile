FROM ubuntu:18.04

  # Prerequisites
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget

  # Set up new user
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu
USER ubuntu
WORKDIR /home/ubuntu

  # Prepare Android directories and system variables
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT /home/ubuntu/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

  # Set up Android SDK
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses
RUN cd Android/sdk/tools/bin && ./sdkmanager "build-tools;29.0.2" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29"
ENV PATH "$PATH:/home/ubuntu/Android/sdk/platform-tools"

  # Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/ubuntu/flutter/bin"

  # Run basic check to download Dark SDK
RUN flutter doctor
#clone the repo inside it
RUN git clone https://github.com/thesandx/MoviesX.git
RUN cp MoviesX/android/app/debug.keystore .android/


#use cd && cmd or WORKDIR , not run cd /movies etc
