FROM centos:8
EXPOSE 8080
EXPOSE 80
EXPOSE 443
EXPOSE 8443
RUN groupadd -g 1000 jenkins
RUN useradd jenkins -u 1000 -g 1000 -m -s /bin/bash
USER 0
RUN yum -y install java-11-openjdk-devel
RUN curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo > /etc/yum.repos.d/jenkins.repo
RUN rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
RUN yum -y install epel-release
RUN yum -y install daemonize
RUN yum -y install jenkins.noarch --nogpgcheck
RUN yum -y install jenkins
RUN chown jenkins:jenkins /var/lib/jenkins
RUN systemctl enable jenkins
USER 1000
