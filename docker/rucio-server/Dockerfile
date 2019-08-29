# Copyright European Organization for Nuclear Research (CERN) 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Eric Vaandering, <ewv@fnal.gov>, 2018


#FROM rucio/rucio-server:release-1.20.2
FROM rucio/rucio-server:release-1.20.4rc3 
RUN pip install rucio==1.20.4rc3

#ADD https://raw.githubusercontent.com/hahahannes/rucio/7a6f218f3a809250c343fc70b0a1e041c092f8da/lib/rucio/api/exporter.py /usr/lib/python2.7/site-packages/rucio/api/exporter.py
#ADD https://raw.githubusercontent.com/fcondo/rucio/24f99fabf7a33ad1823a3669b52bee7754e0829c/lib/rucio/api/exporter.py /usr/lib/python2.7/site-packages/rucio/api/exporter.py
#ADD https://raw.githubusercontent.com/fcondo/rucio/9f0b3d63272d5b8f52c276ef1c85fa5ef02bd822/lib/rucio/api/exporter.py /usr/lib/python2.7/site-packages/rucio/api/exporter.py
ADD https://raw.githubusercontent.com/fcondo/rucio/ecadf59648d49708146fcc9b0f1c4b1c8d49ae1b/lib/rucio/api/exporter.py /usr/lib/python2.7/site-packages/rucio/api/exporter.py
ADD exporter.py /usr/lib/python2.7/site-packages/rucio/api/exporter.py
ADD rucio.conf.j2 /tmp/

ADD https://raw.githubusercontent.com/dmwm/CMSRucio/master/docker/CMSRucioClient/scripts/cmstfc.py  /usr/lib/python2.7/site-packages/cmstfc.py
RUN chmod 755 /usr/lib/python2.7/site-packages/cmstfc.py

RUN yum -y install http://linuxsoft.cern.ch/wlcg/centos7/x86_64/wlcg-repo-1.0.0-1.el7.noarch.rpm
ADD http://repository.egi.eu/sw/production/cas/1/current/repo-files/EGI-trustanchors.repo /etc/yum.repos.d/egi.repo
RUN yum update  -y
RUN yum -y install ca-policy-egi-core
RUN yum -y install ca-certificates.noarch fetch-crl cronie psmisc

ADD cms-entrypoint.sh /

RUN echo "32 */6 * * * root ! /usr/sbin/fetch-crl -q -r 360 ; killall -HUP httpd" > /etc/cron.d/fetch-crl-docker
ADD exporter.py /usr/lib/python2.7/site-packages/rucio/api/exporter.py

ENTRYPOINT ["/cms-entrypoint.sh"]
