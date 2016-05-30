## CentOS 7x Deployment
1. Set up non-root user

        useradd admin
        passwd admin
        usermod -aG wheel admin

  See [this article](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux_OpenStack_Platform/2/html/Getting_Started_Guide/ch02s03.html) for more information.

2. Install C++, wget, net-tools, nmap

  `yum install gcc-c++ wget net-tools nmap`

3. Set up Windows X Desktop Environment and VNC

        yum check-update
        yum groupinstall "X Window System"
        yum install gnome-classic-session gnome-terminal nautilus-open-terminal control-center liberation-mono-fonts
        unlink /etc/systemd/system/default.target
        ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target
        reboot
        
        yum install tigervnc-server -y
        cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
        
        ExecStart=/sbin/runuser -l admin -c "/usr/bin/vncserver %i"
        PIDFile=/home/admin/.vnc/%H%i.pid
        
        systemctl daemon-reload
        vncpasswd
        
        systemctl enable vncserver@:1.service
        systemctl start vncserver@:1.service
        
        systemctl start firewalld.service
        firewall-cmd --permanent --add-service vnc-server
        systemctl restart firewalld.service

  See [this article](http://www.krizna.com/centos/install-vnc-server-centos-7/) for more information.

4. Set up .bashrc aliases and exports

        vi ~/.bashrc
        exports DB_PW=...
        exports SECRET_KEY_BASE=...

  ... other exports?

  `alias cls='clear'`

5. Install ruby, mysql, and development packages

  `yum install ruby ruby-devel mariadb-server mariadb`

6. Configuring mysql (all commands with sudo)

        systemctl start mariadb.service
        systemctl enable mariadb.service
        /usr/bin/mysql_secure_installation

  See [this article](https://support.rackspace.com/how-to/installing-mysql-server-on-centos/) for more information.

7. Download the application files.  This can be done by issuing a wget on the GitHub repository release.

8. cd into the application directory and run `bundle install`.  Make sure you don't have sudo when you run bundle install.
If you run into errors with building native extensions it usually happens because you aren't linking system libraries properly, or are missing a dependency.  Below are some of the bundler problems I've run into, and their resolutions:

  **Nokogiri** (Failed to build gem native extension, extconf.rb failed)
  
  Install libxml2-dev nd libxslt-dev  
  `yum install libxml2-dev libxslt-dev`  
  and install the gem with the use-system-libraries option  
  `gem install nokogiri -- --use-system-libraries=true`
  
  **Event Machine** (Failed to build gem native extension, g++ not found)
  
  You need to install gcc-c++ with yum, per step 2.  
  `yum install gcc-c++`
  
  **therubyracer**
  
  Make sure you have gcc-c++.  
  `gem install libv8 --version=3.11.8.3`  
  `gem install therubyracer --version=0.10.2`
  
  **execjs**
  
  Make sure you have a javascript runtime.  Therubyracer is the default runtime ruby will have you use.
  
  **others**
  
  Google around and pay special attention to suggestions involving installing packages.  Oftentimes things won't work because you're missing dependencies.

9. Create the database and load the schema

  `RAILS_ENV=production rake db:create db:schema:load`

10. Load static seeds with `rake db:seed`.  (NOTE: You need to have seeding properly configured for this step.)

11. Start your rails server.  You may want to set up SSL first if necessary.


### Ruby on Rails SSL Setup with Thin
1. Generate a CSR and Private Key pair.  On Windows you can use [DigicertUtil](https://www.digicert.com/util/).

2. Buy a certificate from NameCheap through RapidSSL (or another trusted provider).

3. Configure your certificate and submit the CSR to generate the needed files.

4. Deploy the certificate and private key to your server.  I recommend putting them in a folder "ssl" in your application's directory.

5. Change any absolute routes in your application to relative routes, if necessary (you should always use relative routes)

6. Configure `app/controllers/application_controller.rb` to force_ssl if not in a development environment.

        # Force application to use ssl if configured
        force_ssl if: :ssl_configured?
        
        def ssl_configured?
          !Rails.env.development?
          # alternatively you could check if the env is production
          #Rails.env.production?
          # or return the force_ssl configuration value
          #Rails.application.config.force_ssl
        end
        
7. Add iptables prerouting to redirect traffic on port 80/443 to port 3000.

 `iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 3000`  
 `iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 3000`

  See [this article](http://www.cyberciti.biz/faq/linux-port-redirection-with-iptables/) for more information.

8. Start Thin with SSL.

  `RAILS_ENV=production thin start -a <YourIP> -p 3000 --ssl --ssl-key-file ssl/<server>.key --ssl-cert-file ssl/<server>.crt`
