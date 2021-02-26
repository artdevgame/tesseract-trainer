# Set docker image
FROM ubuntu:18.04

# Skip the configuration part
ENV DEBIAN_FRONTEND noninteractive

# Update and install depedencies
RUN apt-get update && \
    apt-get install -y wget unzip bc vim python3-pip libleptonica-dev git

# Packages to complie Tesseract
RUN apt-get install -y --reinstall make && \
    apt-get install -y g++ autoconf automake libtool pkg-config libpng-dev libjpeg8-dev libtiff5-dev libicu-dev \
        libpango1.0-dev libcairo2-dev autoconf-archive

# Set working directory
WORKDIR /app

# Copy requirements into the container at /app
# Uncomment next line if you have a requirements.txt file in your hierarchy
# COPY requirements.txt ./      

# Complie Tesseract with training options (also feel free to update Tesseract versions and such!)
RUN mkdir src && cd /app/src && \
  git clone https://github.com/tesseract-ocr/tesseract.git && \
  cd /app/src/tesseract && ./autogen.sh && ./configure --disable-graphics && make && make install && ldconfig && \
  make training && make training-install && \
  cd /usr/local/share/tessdata && wget https://github.com/tesseract-ocr/tessdata_best/raw/master/eng.traineddata

# Setting the data prefix
ENV TESSDATA_PREFIX=/usr/local/share/tessdata

# Set the locale
RUN apt-get install -y locales && locale-gen en_GB.UTF-8
ENV LC_ALL=en_GB.UTF-8
ENV LANG=en_GB.UTF-8
ENV LANGUAGE=en_GB.UTF-8
