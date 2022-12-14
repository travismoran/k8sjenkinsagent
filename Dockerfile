FROM jenkins/inbound-agent:4.11.2-4

# run updates as root
USER root

# Create docker group
RUN addgroup docker

# Update & Upgrade OS
RUN apt-get update
#RUN apt-get -y upgrade
RUN apt-get -y install software-properties-common gnupg2 curl procps
RUN apt-get -y install --no-install-recommends python3-distutils
#RUN add-apt-repository --yes --update ppa:ansible/ansible
RUN echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu bionic main' >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN apt-get -y update
RUN apt-get -y install ansible
# python dependencies
RUN apt-get -y install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev wget
RUN wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz && tar -xvf Python-3.10.0.tgz && cd Python-3.10.0 && ./configure --enable-optimizations && make -j 2 && make altinstall
RUN apt-get -y install python3-pip
RUN pip install regex linecache2 slack_sdk

# uncomment if you need vim or nano
#RUN apt-get -y install vim
#RUN apt-get -y install nano


# Add Maven
#RUN apt-get -y install maven --no-install-recommends

# Add docker
#RUN curl -sSL https://get.docker.com/ | sh
#RUN usermod -aG docker jenkins

# Add docker compose
#RUN curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#RUN chmod +x /usr/local/bin/docker-compose

# Add Telnet

COPY ansible-consul.yml  	/tmp/ansible-consul.yml
COPY ansible-sudoers.yml  	/tmp/ansible-sudoers.yml
COPY datadog.yml  		/tmp/datadog.yml
COPY elastic.yml  		/tmp/elastic.yml
COPY geerlingguy.yml  		/tmp/geerlingguy.yml
COPY sac.py 			/usr/bin/sac

RUN ps aux | grep -i apt
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
# close root access
USER jenkins
RUN ansible-galaxy install -r /tmp/ansible-consul.yml
RUN ansible-galaxy install -r /tmp/ansible-sudoers.yml
RUN ansible-galaxy install -r /tmp/datadog.yml
RUN ansible-galaxy install -r /tmp/elastic.yml
RUN ansible-galaxy install -r /tmp/geerlingguy.yml

RUN az config set extension.use_dynamic_install=yes_without_prompt
