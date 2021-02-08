FROM ubuntu:18.04

ARG DEV=false

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Setting timezone 
ENV TZ=Europe/Copenhagen
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Setup user 
RUN useradd -m user -p "$(openssl passwd -1 user)"
RUN usermod -aG sudo user 

COPY ./root /home/user
# Extra
RUN apt update && apt install -y vim \
                                 ssh \
                                 openssh* \
                                 sudo \
                                 gdb \
               && rm -rf /var/lib/apt/lists/*

# Installing Dependencies:
RUN apt update && apt install -y g++ \
                   make \
                   automake \
                   libtool \
                   xutils-dev \
                   m4 \
                   libreadline-dev \
                   libgsl0-dev libglu-dev \
                   libgl1-mesa-dev \
                   freeglut3-dev \
                   libopenscenegraph-dev \
                   libqt4-dev \
                   libqt4-opengl \
                   libqt4-opengl-dev \
                   qt4-qmake \
                   libqt4-qt3support \
                   gnuplot \
                   gnuplot-x11 \
                   libncurses5-dev \
                   libgl1-mesa-dev \
               && rm -rf /var/lib/apt/lists/*


# Installing the workspace
RUN mkdir /home/user/workspace
RUN mkdir /home/user/bin

WORKDIR /home/user/workspace
RUN apt update && apt install -y git && git clone "https://github.com/pmanoonpong/gorobots_edu.git"
RUN git clone "https://github.com/pmanoonpong/lpzrobots.git"

WORKDIR /home/user/workspace/lpzrobots
RUN echo "TYPE=DEVEL" >> Makefile.conf && make all -j4
RUN ln -sf /home/user/workspace/lpzrobots/opende/ode/src/.libs/libode_dbl.so.1 /lib/libode_dbl.so.1

WORKDIR /home/user/workspace
RUN cp lpzrobots/ode_robots/simulations/template_amosii/Makefile gorobots_edu/practices/amosii

WORKDIR /home/user/workspace/gorobots_edu/practices/amosii
RUN export PATH=/home/user/bin/:$PATH && make

# Changing the own of the workspace
RUN chown -R user:user /home/user/workspace
# Setting python
#RUN rm /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python 

RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
RUN mkdir /var/run/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN apt update && apt install -y cmake && rm -rf /var/lib/apt/lists/*
WORKDIR /
RUN if [ "$DEV" != "false" ]; then apt update && apt install -y cppcheck && rm -rf /var/lib/apt/lists/*; fi
COPY ./cquery_install.sh /
RUN if [ "$DEV" != "false" ]; then bash /cquery_install.sh; rm -r cquery; fi
RUN rm /cquery_install.sh
               

# Setting user and the workdir
USER user
WORKDIR /home/user 


