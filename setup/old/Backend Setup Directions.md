### Step 1:
Download [MySQL 5.6](https://dev.mysql.com/downloads/mysql/5.6.html)
(do the x64 zip installer)

### Step 2:
Extract the folder from the archive wherever you want. I'd recommend using folder like `C:\dev\db\`

### Step 3:
Download [Ruby 2.0.0-p647 (x64) and the mingw 64-bit devkit](http://rubyinstaller.org/downloads/)

### Step 4:
Run the ruby installer and make sure to check the box to add ruby executables to your path.  
I recommend installing in a folder like `C:\dev\lang\`.  
Extract the devkit in the ruby folder in a folder called devkit.  
Follow the [Quick Start instructions for setting up the devkit](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit).  
Make sure to edit the `config.yml` file to add your ruby path if it wasn't found automatically.

### Step 5:
Add the mysql bin folder to your system's [%path% environment variable](https://dev.mysql.com/doc/mysql-windows-excerpt/5.1/en/mysql-installation-windows-path.html).
Run the mysqld service using `Win+R`.

### Step 6:
Run a command window in any directory, and type `gem install rails '~> 4.2.5'`.  You'll have to wait a while for it to fully download and install all required packages.

### Step 7:
Go to the mod-picker directory in the mod-picker repo, open a command window, and type `bundle install`.  This will install all gems (dependencies) that are missing.

### Step 8:
In the same command window type `setup.bat`.  This should set up databases for the platform.  The development database is `mod_picker_dev`.

### Step 9:
In the same command window type `rails server`.  Your server should now be running!  :)

### Step 10:
In a new command window type `mailcatcher`.  This will run mailcatcher so you can get your registration email.

### Step 11:
Open your internet browser and navigate to [localhost:3000](http://localhost:3000).  You can navigate to various pages from the homepage.

### Step 12:
Click register to register an account.  Once you've created the account you'll need to navigate to [localhost:1080](http://localhost:1080) to get the confirmation email and confirm your account.
