#!/bin/bash

#Install firewallD and start service(make sure it runs  even after reboot)
sudo yum install -y firewalld
sudo service firewalld start
sudo systemctl enable firewalld

#Install mariaDB server(database) and configure
sudo yum install -y maria-db server

#sudo vi /etc/my.cnf(default config settings)

sudo service mariadb start
sudo systemctl enable mariadb

#config firewall for database
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

#configure database
mysql
MariaDB > CREATE DATABASE ecomdb;
MariaDB > CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
MariaDB > GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
MariaDB > FLUSH PRIVILEGES;

#load Product Inventory to db
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

#run sql script
sudo mysql < db-load-script.sql

#Deploy and configure web
sudo yum install -y httpd php php-mysql
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

Change DirectoryIndex index.html to DirectoryIndex index.php to make the php page the default page
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

#start httpd (apache)
sudo service httpd start
sudo systemctl enable httpd

#clone repo
sudo yum install -y git
git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

#update index.php to connect to the right database server. In this case localhost since the database is on the same server.
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

              <?php
                        $link = mysqli_connect('172.20.1.101', 'ecomuser', 'ecompassword', 'ecomdb');
                        if ($link) {
                        $res = mysqli_query($link, "select * from products;");
                        while ($row = mysqli_fetch_assoc($res)) { ?>
#test
curl http://localhost
