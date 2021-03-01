FROM kindest/node:v1.19.7

RUN echo "deb http://de.archive.ubuntu.com/ubuntu/ focal main" > "/etc/apt/sources.list"
#RUN echo "deb-src http://de.archive.ubuntu.com/ubuntu/ focal main multiverse restricted universe" > "/etc/apt/sources.list"

RUN apt-get update -y
RUN apt-get install -y make

COPY scripts/ src/scripts
COPY templates/ src/templates 
COPY Makefile src/Makefile
COPY requirements.txt src/requirements.txt

workdir src/

ENTRYPOINT ["kubeadm version"]