FROM ubuntu
RUN apt-get update
RUN apt-get install -y docker.io
RUN apt-get install -y vim
RUN apt-get install -y python3.8
RUN apt-get install -y python3-pip
RUN apt-get install -y iputils-ping
RUN apt-get install -y git
RUN pip install kubernetes
RUN pip install pymongo
RUN pip install dnspython
RUN echo "nameserver 8.8.8.8" >> /etc/resolv.conf
RUN echo "set tabstop=4" >> ~/.vimrc
RUN mkdir /python
CMD bash -c "'nameserver 8.8.8.8' >> /etc/resolv.conf"
