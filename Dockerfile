FROM centos:7

# Install Repos for Python, Node, and R
RUN yum install epel-release https://centos7.iuscommunity.org/ius-release.rpm -y
RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -

RUN yum groupinstall -y 'Development Tools' && \
    yum -y install ruby-devel gcc curl libyaml-devel rpm-build make && \
    gem install --no-ri --no-rdoc fpm && \
    yum -y install openssl-devel readline-devel \
    bzip2-devel sqlite-devel zlib-devel ncurses-devel libjpeg-devel \
    db4-devel expat-devel gdbm-devel \
    python35u python35u-devel \
    R R-Dev nodejs nodejs-devel \
    ruby ruby-devel \
    && mkdir -p /build/src

ARG VERSION=3.0.12
ARG MAJOR_VERSION=3.0
ARG BUILDOUT_CFG=buildout.3.0.cfg

WORKDIR /build
COPY ${BUILDOUT_CFG} /build/buildout.cfg
COPY bootstrap.py /build

RUN python bootstrap.py
 RUN ./bin/buildout -vv && \
     echo 'echo /usr/local/lib > /etc/ld.so.conf.d/usr-local-lib.conf' > /tmp/installdir/run-ldconfig.sh && \
     echo '/sbin/ldconfig' >> /tmp/installdir/run-ldconfig.sh

 RUN fpm -s dir -t rpm -n swig -v ${VERSION} -C /tmp/installdir \
     --after-install /tmp/installdir/run-ldconfig.sh \
     usr/local

RUN rpm -i swig*.rpm

COPY tests /build/tests
RUN cd tests && make
# RUN swig -javascript -node -c++ example.i
# npm install -g node-gyp
# node-gyp configure
# RUN node-gyp build
#     
# RUN swig -python example.i