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
