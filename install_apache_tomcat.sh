#! /bin/bash
#iInstalação do Tomcat
sudo apt-get update
sudo apt install default-jdk -y
sudo apt install tomcat9 tomcat9-admin -y
sudo systemctl start tomcat9
sudo systemctl enable tomcat9


# instalação do apache
#sudo apt-get install -y apache2
#sudo systemctl start apache2
#sudo systemctl enable apache2


