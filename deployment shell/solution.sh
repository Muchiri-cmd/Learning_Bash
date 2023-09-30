#!/bin/bash
#automation - deploys a single node ecommerce app
#print success and error messages in color for better readability
function print_color (){
  NC='\033[0m'
  case $1 in
    red)
      COLOR='\033[0;31m'
      ;;
    green)
      COLOR='\033[0;32m'
      ;;
    *)
      COLOR='\033[0m'
      ;;
  esac
  echo -e "${COLOR}$2${NC}"
}

#checks the status of services
function check_service_status(){
  service=$1
  is_service_active=$(sudo systemctl is-active $service)
  if [ $is_service_active = "active" ]; then
    print_color "green" "$service is active"
  else
    print_color "red" "$service is not active"
    exit 1
  fi
}

function is_firewalld_configured(){
  firewall_ports=$(sudo firewall-cmd --list-all --zone=public| grep ports)
  if [[ $firewall_ports == *$1* ]]; then
    print_color "green" "firewall rules for database added successfully.Port $1 is open"
  else
    print_color "red" "firewall rules for database not added.Port $1 is not open"
    exit 1
  fi

}

function check_item(){
  
  if [[ $1 = *$2* ]]; then
    print_color "green" "Item $2 loaded on Website"
  else
    print_color "red" "Item $2 not loaded on Website"
    exit 1
  fi
}

#Install firewallD and start service(make sure it runs  even after reboot)
print_color "green" "....installing firewallD and starting service"
sudo yum install -y firewalld
sudo service firewalld start
sudo systemctl enable firewalld

#check if firewallD is active
check_service_status firewalld

#Install mariaDB server(database) and configure
print_color "green" "....installing mariaDB.."
sudo yum install -y mariadb-server


#sudo vi /etc/my.cnf(default config settings)
print_color "green" "....configuring mariaDB service"
sudo service mariadb start
sudo systemctl enable mariadb
#check if mariadb is active
check_service_status mariadb

#config firewall for database
print_color "green" "...Adding firewall rules for database"
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

is_firewalld_configured 3306

#configure database
print_color "green" "....creating database and user"  
cat > setup-db.sql <<-EOF
CREATE DATABASE ecomdb;
CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
FLUSH PRIVILEGES;
EOF


#run sql script
sudo mysql < setup-db.sql

#load Product Inventory to db
print_color "green" "....loading product inventory to database"
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

#run sql script
sudo mysql < db-load-script.sql

#check if items were added to database by sampling laptop
print_color "green" "....checking if items were added to database"
mysql_db_items=$(sudo mysql -e "USE ecomdb; SELECT * FROM products;")
if [[ $mysql_db_items == *Laptop* ]]; then
  print_color "green" "Items added to database successfully"
else
  print_color "red" "Items not added to database"
  exit 1
fi

#Deploy and configure web
print_color "green" "....deploying and configuring webserver"

print_color "green" "....installing httpd and php"
sudo yum install -y httpd php php-mysql

print_color "green" "Setting firewall rules for webserver" 
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

is_firewalld_configured 80

Change DirectoryIndex index.html to DirectoryIndex index.php to make the php page the default page
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

#start httpd (apache)
print_color "green" "....starting webserver"
sudo service httpd start
sudo systemctl enable httpd
check_service_status  httpd

#clone repo
print_color "green" "....cloning repo"
sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

#update index.php to connect to the right database server. In this case localhost since the database is on the same server.
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

print_color "green" "All done.Scripting is fun!"

#test web page  
#check if items loaded to site by sampling

web_page=$(curl http://localhost)
for item in Laptop Drone VR Tablet Watch Phone Covers Phone Laptop
do
  check_item "$web_page" $item
done