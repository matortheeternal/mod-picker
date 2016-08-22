# mod-picker
A web application which helps users to pick mods to use in Bethesda Games such as Skyrim and Fallout 4.

## How to install
### Windows Machines
If you are running on Windows, you will need GitBash. You can download it from here: [git](https://git-scm.com/download/win)

### Virtualbox
Install VirtualBox if you don't have it:
https://www.virtualbox.org/wiki/Downloads

### Vagrant
Install vagrant if you don't have it:
http://docs.vagrantup.com/v2/installation/

### Clone the repo
```bash
git clone https://github.com/matortheeternal/mod-picker.git
cd mod-picker
```

### Create config files
```bash
cp vagrant.yml.example vagrant.yml
cp config/database.yml.example config/database.yml
```

Edit the two config files you just created and add the database password you want to use to line 5 in ```vagrant.yml``` and lines 14 and 22 in ```database.yml```

### Generate Vagrant
**This step may take a half hour or more depending on how long it takes you to download all the necessary installers and build Ruby.**

You may need to install some vagrant plugins if you don't have them yet. The ```vagrant up``` step below should tell you the EXACT commands you need to install them if you don't have them already installed.

```bash
vagrant up
```

### Log into the Vagrant Client
```bash
vagrant ssh
```

### Start the services
```bash
rails s
```

### Development
You should be able to develop from either within the VM or from your Mac, Windows, or Linux machine as the folder is shared between the VM and your host computer. You can reach the rails server by going to http://localhost:3000 in your browser

### Making changes to the codebase
- No changes should be directly pushed to any of the following branches: master
- All changes should be made on a branch and a pull-request should be created on github (see https://help.github.com/articles/using-pull-requests/)
- Use the following workflow to make changes:
  - Create a new branch based off of master (git checkout -b new_branch_name origin/master)
  - Make your code changes
  - Push your new branch up to github (git push origin new_branch_name)
  - Open a Pull Request to master with your changes (see https://help.github.com/articles/using-pull-requests/)
  - Other developers can then approve your pull request and merge the code in!

### Tooling
Here is a list of tools you may find useful as you develop:
[GitHub for Windows](https://desktop.github.com/) (for Windows machines)
[Sourcetree](https://www.sourcetreeapp.com/) (highly recommended if you are new to Git) (See below for some help)

### Workflow Guidelines
- Refer to the Trello board for items tagged as "Frontend" (the blue bar) for pages to work on developing.  You can also choose your own page to work on (see "Choosing a page to work on").
- Once you've edited a page you can view it by navigating to its route.  You may have to restart the server if you added images in developing the page. (Use `CTRL + C` to stop the server and `rails s` to start it again).

Feel free to ask questions in the Development Team's Discord channels

### Cloning the repository with Sourcetree

1. Download [Sourcetree](https://www.sourcetreeapp.com/). (works on Windows and Mac)
2. Run the Sourcetree installer.
3. Open Sourcetree and set up your GitHub account.
4. Click on the Clone / New button in SourceTree (in the upper left corner).
5. Paste the clone url for this repository into the Source Path / URL field (you can find it on the [main repository page](https://github.com/matortheeternal/mod-picker)).  Here is the url for convenience:   `https://github.com/matortheeternal/mod-picker.git`.
![Screenshot](http://puu.sh/mtxD3.png)
*How to get the clone URL for the repository.*
6. Specify the path you want to clone to (I use `E:\dev\git\<repository-name>`).
7. Click Clone.

### Making a branch with Sourcetree

1. While the mod-picker repository is selected, click the branch button in Sourcetree.
2. Name the branch.  You should name branches after the feature/page you're developing on that branch.
3. Commit and push the branch once you've made a change on it.

### Commiting and pushing code with SourceTree
1. Select the changes you want to commit in the File Status tab to move them to the "Staged Files" section.
2. Enter a commit message detailing your changes.  Start with a short summary of your commit (like a title), then go into more detail on subsequent lines.
3. Check "Push changes immediately to \<branch\\name\>", then click Commit.

## Frontend development

### HTML and CSS basics

The following resources are great for learning HTML and CSS:

* [w3schools html](http://www.w3schools.com/html/)
* [CodeAcademy HTML & CSS](https://www.codecademy.com/learn/web)
* [MDN - Learning the Web](https://developer.mozilla.org/en-US/Learn/HTML)

### html.erb

`.html.erb` files are ruby-enhanced html documents.  You can do anything you can do on an HTML document on these pages, with the added benefit of inline ruby code that gets pre-processed before the page is served up to the user.  Inline ruby code will have `<%` bracket percent `%>` tags around it.

See the following resources information on .html.erb files:

* [Layouts and Rendering in Rails](http://guides.rubyonrails.org/layouts_and_rendering.html)
* [An introduction to ERB templating](http://www.stuartellis.eu/articles/erb/)

### Application-wide css

A safe place to add CSS in these early stages is the `mod-picker\app\assets\stylesheets\application.css` document.  CSS added in this file will be available to all pages on the website.  We'll be refactoring css out of this document into page-specific SCSS documents as the project progresses.

### Choosing a page to work on

If you're looking to do frontend development you can scope out pages to work on in the site map document.
