# Copyright © 2018 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
FROM williamyeh/ansible:ubuntu16.04
RUN apt-get update -qq && apt-get install -y x11vnc xvfb fluxbox python-apt
RUN mkdir ~/.vnc
# Setup a VNC password
RUN x11vnc -storepasswd 1234 /etc/x11vnc.pass

RUN echo "Install noVNC - HTML5 based VNC viewer"
RUN mkdir -p /novnc/utils/websockify
RUN apt-get install wget net-tools
RUN wget -qO- https://github.com/novnc/noVNC/archive/v1.0.0.tar.gz | tar xz --strip 1 -C /novnc
# use older version of websockify to prevent hanging connections on offline containers, see https://github.com/ConSol/docker-headless-vnc-container/issues/50
RUN wget -qO- https://github.com/novnc/websockify/archive/v0.6.1.tar.gz | tar xz --strip 1 -C /novnc/utils/websockify
RUN chmod +x -v /novnc/utils/*.sh
## create index.html to forward automatically to `vnc_lite.html`
RUN ln -s /novnc/vnc_lite.html /novnc/index.html
RUN echo "export DISPLAY=:2" >> /novnc/novnc.sh
RUN echo "Xvfb :2 -screen 0 1280x800x16 &" >> /novnc/novnc.sh
RUN echo "x11vnc -forever -usepw -display :2 -rfbauth /etc/x11vnc.pass &" >> /novnc/novnc.sh
RUN echo "xterm -e 'cd /code && /bin/bash' &" >> /novnc/novnc.sh
RUN echo "fluxbox &" >> /novnc/novnc.sh
RUN echo "/novnc/utils/launch.sh" >> /novnc/novnc.sh
RUN chmod +x -v /novnc/*.sh
EXPOSE 6080

RUN mkdir /vnc
RUN echo "export DISPLAY=:20" >> /vnc/vnc.sh
RUN echo "Xvfb :20 -screen 0 1280x800x16 &" >> /vnc/vnc.sh
RUN echo "x11vnc -forever -usepw -display :20 -rfbport 5920 -rfbauth /etc/x11vnc.pass &" >> /vnc/vnc.sh
RUN echo "xterm &" >> /vnc/vnc.sh
RUN echo fluxbox >> /vnc/vnc.sh
RUN chmod +x -v /vnc/*.sh
EXPOSE 5920

VOLUME /code
ADD . /code
WORKDIR /code

# These arguments assume the local inventory and extra_vars is already created.
CMD ["site.yml", "-i", "inventory", "--extra-vars", "@extra_vars.yml"]
ENTRYPOINT ["ansible-playbook"]
