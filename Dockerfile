FROM quaive/ploneintranet-base:mars.3

RUN addgroup --gid 500 plone \
    && adduser --home /plone --ingroup plone --uid 500 --disabled-password --gecos '' plone \
    && mkdir -p /plone /plone/var/zeoserver /plone/var/filestorage /plone/var/blobstorage \
    && mkdir -p /plone/var/instance /plone/var/instance1 /plone/var/instance2 /plone/var/instance3 /plone/var/instance4 \
    && chown -R plone:plone /plone
ADD . /plone
RUN ln -s /var/tmp/eggs /plone/eggs \
    && ln -s /var/tmp/downloads /plone/downloads \
    && ln -s /var/tmp/extends /plone/extends \
    && mv /tmp/requirements.txt /plone
WORKDIR /plone
RUN cd /plone \
    && virtualenv -p python2.7 . \
    && bin/pip install -r requirements.txt \
    && bin/buildout -c buildout.cfg \
    && find /plone \( -type f -a -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' + \
    && chown -R plone:plone /plone
USER plone
VOLUME /plone/var
HEALTHCHECK --start-period=1m --timeout=10s --interval=1m CMD curl --fail http://127.0.0.1:8080/ || exit 1
EXPOSE 8080
CMD ["/bin/bash"]
