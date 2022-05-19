Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
sudo yum update -y

#install java:11
sudo amazon-linux-extras install java-openjdk11 -y
export JAVA_HOME=$(echo /usr/lib/jvm/)$(echo $(ls /usr/lib/jvm | grep "java-11-openjdk*"))

#install maven:3.5.4
wget https://archive.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
tar -zxvf apache-maven-3.5.4-bin.tar.gz
sudo mv apache-maven-3.5.4 /opt
sudo chown -R root:root /opt/apache-maven-3.5.4
sudo ln -s /opt/apache-maven-3.5.4 /opt/apache-maven
echo 'export PATH=$PATH:/opt/apache-maven/bin' | sudo tee -a /etc/profile
source /etc/profile

#install git
sudo yum install git -y

#clone codenjoy repo
git clone https://github.com/codenjoyme/codenjoy.git

#checkout working commit
cd codenjoy
sudo git checkout 7c8e2ceb2d74dcb18a344ca32bcacf5bd4a2bb39

#lanch codenjoy server
cd CodingDojo/games/engine/
mvn clean install -N -DskipTests=true
cd ..
mvn clean install -N -DskipTests=true
cd bomberman
mvn clean install -N -DskipTests=true
cd ../../server
nohup mvn clean spring-boot:run -DMAVEN_OPTS=-Xmx1024m -Dmaven.test.skip=true -Dspring.profiles.active=sqlite,bomberman,debug -Dcontext=/codenjoy-contest -Dserver.port=80 -Pbomberman &
