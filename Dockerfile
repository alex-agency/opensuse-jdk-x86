FROM opensuse
MAINTAINER Alex

# Variables
ENV USER_PASSWD  password
ENV ROOT_PASSWD  password

# Add user
RUN zypper --non-interactive update && \
    zypper --non-interactive install sudo && \
    zypper --non-interactive clean && rm -rf /tmp/* && \
    useradd user -m && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    su user echo "user:$USER_PASSWD" | chpasswd
ENV HOME /home/user
WORKDIR /home/user

RUN zypper --non-interactive update && \
    zypper --non-interactive install wget tar bzip2 firefox.i586 \
        libXtst6-32bit gtk2-tools.i586 gtk2-devel.i586 && \
    zypper --non-interactive clean && rm -rf /tmp/*
RUN echo "root:$ROOT_PASSWD" | chpasswd

# JDK x86
ENV JDK_URL http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-linux-i586.rpm
RUN wget -c --no-cookies  --no-check-certificate  --header \
"Cookie: oraclelicense=accept-securebackup-cookie" $JDK_URL -O jdk.rpm && \
    rpm -i jdk.rpm && rm -fv jdk.rpm
# Firefox x86 Java plugin
RUN ln -s /usr/sbin/update-alternatives /usr/sbin/alternatives && \
    mkdir -p /usr/lib/mozilla/plugins && \
    alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so libjavaplugin.so \
    /usr/java/latest/jre/lib/i386/libnpjp2.so 200000

# Eclipse Luna x86
ENV ECLIPSE_URL http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads\
/release/mars/1/eclipse-jee-mars-1-linux-gtk.tar.gz
RUN wget $ECLIPSE_URL && \
    tar -zxvf `echo "${ECLIPSE_URL##*/}"` -C /opt/ && \
    ln -s /opt/eclipse/eclipse /usr/bin/eclipse && \
    rm -f `echo "${ECLIPSE_URL##*/}"`

# Default user
USER user
