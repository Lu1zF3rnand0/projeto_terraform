#! /bin/bash
#install apache
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2

#install JDK
sudo apt install default-jdk -y

#install mysql mysql
sudo apt install mysql-client -y

#Create MySQL config file
#echo "[mysql]" >> ~/.my.cnf
#echo "user = admin" >> ~/.my.cnf
#echo "password = password123" >> ~/.my.cnf

#test
#echo "endpoint = ${rds_endpoint}" >> ~/variables
#hostip=$(hostname -I)
#endpoint=${rds_endpoint}
#echo "$hostip" >> ~/variables