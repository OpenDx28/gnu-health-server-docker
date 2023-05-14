# docker build -t opendx/gnu_health .
# Create a docker container based on the previous image
# docker run -it --rm -p 8000:8000 -p 9000:9000 --name gnuhealth opendx/gnu_health
# https://en.wikibooks.org/wiki/GNU_Health/Installation
# 3.1
FROM ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install \
    apt-utils \
    build-essential \
    git-core \
    gcc \
    curl \
    wget \
    vim \
    openssl \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    python3-dev \
    pkg-config \
    libfreetype6-dev \
    postgresql \
    patch \
    python3-pip \
    unoconv \
    libpq-dev \
    libpng-dev \
    libjpeg8-dev \
    graphviz \
    libreoffice-core \
    default-jre \
    libreoffice-java-common \
    expect

# NODE (for Tryton SAO)
RUN apt-get install -y apt-utils
RUN curl -sL https://deb.nodesource.com/setup_19.x | bash -
RUN apt-get install -y nodejs

# uWSGI (for an improved web server)
# supervisor for multiple processes, to initialize thalamus config
# proteus, also to initialize thalamus config
# pydot for graph of objects
RUN pip install uwsgi "proteus>=6.0,<6.1" supervisor pydot

# 3.2 Setting up NTP

# 3.3 Create OS user
#RUN adduser gnuhealth
RUN groupadd -r -g 10001 gnuhealth && useradd -r -u 10001 -g gnuhealth -m -s /bin/bash -c "GNU Health" gnuhealth

# 3.4 Verify Postgres authentication method (does not apply)
# 3.5 Create database user (in the Docker Compose, PostgreSQL image)

# 3.6 Install GNU Health (3.6.1.1, 3.6.1.2, 3.6.1.4, 3.6.1.5, 3.6.1.6)
# TODO 3.6.1.2 Verify GPG signature
USER gnuhealth
RUN cd /home/gnuhealth && \
    wget https://ftp.gnu.org/gnu/health/gnuhealth-4.2.0.tar.gz && \
    tar -xvf gnuhealth-4.2.0.tar.gz && \
    cd gnuhealth-4.2.0 && \
    wget -qO- https://ftp.gnu.org/gnu/health/gnuhealth-setup-latest.tar.gz | tar -xzvf -

# 3.6.1.7, 3.6.1.8
WORKDIR /home/gnuhealth/gnuhealth-4.2.0
ENV PATH="$PATH:/home/gnuhealth/.local/bin"
RUN ./gnuhealth-setup install && \
    head -n -6 $HOME/.gnuhealthrc > tmp.txt && mv tmp.txt $HOME/.gnuhealthrc && \
    echo PS1=\""\[\e[96;2m\]\u@\h \w $ \[\e[0m\]\"" >> $HOME/.gnuhealthrc && \
    chmod u+x ${HOME}/.gnuhealthrc && ${HOME}/.gnuhealthrc

# Install Tryton SAO, extracted at /home/gnuhealth/sao
# Also: https://downloads.tryton.org/6.6/tryton-sao-6.6.4.tar.gz
RUN cd /home/gnuhealth && \
    wget -qO- https://hg.tryton.org/sao/archive/6.6.1.tar.gz | tar -xzvf - && \
    mv sao-6.6.1 sao && \
    cd sao
    # && npm install --production --legacy-peer-deps
# TODO Previous line Disabled!!! (no web GUI!. Use Python Client. The command "npm" stopped working)

RUN cd ~ && \
    wget -qO- https://www.gnuhealth.org/downloads/postgres_dumps/gnuhealth-42-demo.sql.gz | gunzip > demo.sql && \
    chown gnuhealth:gnuhealth demo.sql

ENV DB_NAME=ghs
ENV DB_USER=gnuhealth
ENV DB_PASSWORD=gnuhealth
ENV DB_HOST=postgres
ENV ADMIN_PASSWORD=opendx28
# IF defined it will use the demo database, if not it will create an empty one
ENV DEMO_DB=1

# Make the last a volume
COPY --chown=gnuhealth:gnuhealth trytond.conf /home/gnuhealth/gnuhealth/tryton/server/config
# PREVIOUS CHECK: ensure "start.sh" has execution permissions for "user" (chmod u+x start.sh)
COPY --chown=gnuhealth:gnuhealth start.sh /home/gnuhealth/start.sh
COPY --chown=gnuhealth:gnuhealth set_thalamus_config.py /home/gnuhealth/set_thalamus_config.py
COPY --chown=gnuhealth:gnuhealth set_admin_password.exp /home/gnuhealth/set_admin_password.exp
COPY supervisord.conf /etc/supervisord.conf

VOLUME /home/gnuhealth/gnuhealth/tryton/server/modules/local
RUN chown -R gnuhealth:gnuhealth /home/gnuhealth/gnuhealth/tryton/server/modules/local

ENV PGPASSWORD=gnuhealth
#CMD ["/bin/bash", "/home/gnuhealth/start.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
#CMD ["sleep", "infinity"]