FROM ubuntu:22.04
MAINTAINER Razorcat GmbH <support@razorcat.com>

ENV DEBIAN_FRONTEND=noninteractive
#
# Add Razorcat's public repository
#
ADD razorcat.gpg /etc/apt/trusted.gpg.d/razorcat.gpg

RUN  echo 'deb [arch=amd64] http://www.razorcat.com/deb/ jammy non-free' \
 >>/etc/apt/sources.list.d/razorcat.list

#
# Install needed packages
#
RUN apt-get update && \
    apt-get install -y -q --no-install-recommends \
	ca-certificates \
	dumb-init \
	gosu \
	libcups2 \
	libfontconfig1 \
	libfreetype6 \
	libgtk-3-0 \
	libharfbuzz0b \
	libjpeg8 \
	liblcms2-2 \
	libnss3 \
	libpcsclite1 \
	libx11-6 \
	libxext6 \
	libxi6 \
	libxrender1 \
	libxtst6 \
	rc-tessy-5.1 \
	util-linux \
	xvfb \
        && rm -rf /var/lib/apt/lists/*


#
# Setup license access
#
ARG RAZORCAT_FLS_HOST=host.docker.internal
ENV RAZORCAT_FLS_HOST=$RAZORCAT_FLS_HOST



#
# TESSY needs an X Server to create reports therefore xvfb will be used
#
ENV DISPLAY=:1
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint.sh"]


# provide hotfixes as tar files next the dockerfile, e.g. tessy_5.1.8_hotfix_0_1.tar.gz
ADD tessy_*.tar.gz /opt/razorcat/TESSY_5.1/
