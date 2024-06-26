# CPU Deployment
# Pulling base image from local Nexus server, if cloning externally, uncomment all lines
#FROM 192.168.50.25:5000/base-images/cpu-base:latest
FROM centos:7

# Assign maintainer
LABEL maintainer="huwenkai@gmail.com"

# Install pip
RUN set -xe \
	&& yum install -y python3-pip epel-release
RUN yum install -y jq
RUN pip3 install --upgrade pip

# Set pip.conf
RUN export PIP_CONFIG_FILE=/.config/pip/pip.conf

# Set the local directory
WORKDIR /app
COPY ./requirements.txt /app/requirements.txt

#  Get python libraries from nexus server
RUN pip3 install -r requirements.txt
# Install torch for cpu
RUN pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
RUN python3 -m nltk.downloader punkt

# Copy dir
COPY . /app

# Create directory for models to be stored
RUN mkdir /app/models

# Convert all models needed for translations
RUN sh ct2-model-converter.sh ./models/lang_abbr_key.json

# Run flask API
ENTRYPOINT ["python3", "app/app.py"]
EXPOSE 5000
