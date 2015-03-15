sudo apt-get install mysql-server python-mysqldb -y

read -p  "Enter The password you would like to use for the cuckoo db user[ENTER]: " cuckoopass
if ["$cuckoopass" = ""]; then
 echo "you didn't enter a password exiting"
 exit
else
 echo "create database cuckoo;
 grant all privileges on cuckoo.* to cuckoo@localhost identified by '$cuckoopass';
 flush privileges;
 quit;" > dbsetup.txt

 echo "You will be prompted for the root mysql password to setup cuckoo db"
 mysql -u root -p mysql < dbsetup.txt
 rm dbsetup.txt

 echo "You will need to add the following to the db config in your cuckoo.conf\n
 connection=mysql://cuckoo:$cuckoopass@localhost/cuckoo"
fi
