FROM jenkins/jenkins:lts
ENV JAVA_OPTS="-Xmx8192m"
ENV JENKINS_OPTS=" --handlerCountMax=300 --logfile=/var/log/jenkins/jenkins.log"
USER root
RUN mkdir /var/log/jenkins
RUN chown -R jenkins:jenkins /var/log/jenkins
USER jenkins