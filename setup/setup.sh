# This is the Mod Picker server set up script
# 
# Before running this, make sure you have 7-zip installed per the following commands:
#   yum install epel-release
#   yum install p7zip -y
#

## SETUP ADMIN USER
useradd admin
passwd admin
usermod -aG wheel admin
su - admin

# Profile setup
7za x -y -o~ setup.7z
source ~/.bashrc
cls

# Shared variable setup
echo "Input release version"
read version

## SECURE SSH
systemctl start filewalld
sudo firewall-cmd --permanent --zone=public --add-port=3772/tcp
sudo firewall-cmd --reload
sudo vi /etc/ssh/sshd_config
systemctl restart sshd.service
ss -tnlp|grep ssh

# Package installation
## GENERAL DEPENDENCIES
sudo yum install -y epel-release yum-utils nano wget
sudo yum-config-manager --enable epel
sudo yum clean all && sudo yum update -y
sudo yum install -y pygpgme curl

## MARIADB
sudo yum install mysql-devel -y
sudo yum install mariadb-server -y
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo mysql_secure_installation

## REDIS
wget -r --no-parent -A 'epel-release-*.rpm' http://dl.fedoraproject.org/pub/epel/7/x86_64/e/
rpm -Uvh dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-*.rpm
yum install redis -y
systemctl start redis.service
redis-cli ping

## RVM and RUBY
yum groupinstall -y development
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm reload
rvm install 2.3.1
usermod -aG rvm admin

## BUNDLER
gem install bundler

## PASSENGER and NGINX
sudo curl --fail -sSLo /etc/yum.repos.d/passenger.repo https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo
sudo yum install -y nginx passenger || sudo yum-config-manager --enable cr && sudo yum install -y nginx passenger
systemctl start nginx
sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
systemctl enable nginx
mv -f nginx.conf /etc/nginx/nginx.conf
sudo service nginx restart
sudo /usr/bin/passenger-config validate-install

# Directory set up
mkdir -p /var/www/mod-picker/releases
cd /var/www/mod-picker
mv shared /var/www/mod-picker/shared
mv ~/deploy /var/www/mod-picker/deploy
chmod +x deploy
chmod 755 /var/www/mod-picker
chown admin /var/www/mod-picker

# DEPLOY
echo
echo "Version: ${version}"
release="mod-picker-${version}"

archive="${release}.zip"
echo "Extracting release ${archive}"
7za x -oreleases $archive

echo
folder="releases/${release}/mod-picker"
echo "Symlinking shared files"
echo "Release folder: ${folder}"
ln -s $folder current
ln -s shared/ssl current/ssl
ln shared/config/database.yml current/config/database.yml

echo
echo "Bundling"
cd current
bundle install --path ~/.gem

echo 
echo "Precompiling assets"
rake assets:precompile RAILS_ENV=production
