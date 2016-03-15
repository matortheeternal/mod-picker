# mod-picker
A web application which helps users to pick mods to use in Bethesda Games such as Skyrim and Fallout 4.

## Quick-start guide

Below is a list of instructions and resources for setting up a development environment to work on the mod-picker project.  This is a great way to get started.

If you have any problems following these directions feel free to ask for help on the team's Slack.

1. Clone the repository.  There are multiple ways you can do this, including [Sourcetree](https://www.sourcetreeapp.com/), [GitHub for Windows](https://desktop.github.com/), and the command line (via [git](https://git-scm.com/downloads)).  See the section "Cloning the repository with Sourcetree" for more information.
2. Open the directory where you cloned the repository to.  You should find a copy of this `README.md` file and various folders.
3. Open the `setup` folder and view the `Backend Setup Directions.md` file.  This file instructs you on how to set up the server so you can run the website for the purposes of development on your computer.  You can also [view the file on GitHub](https://github.com/matortheeternal/mod-picker/blob/master/setup/Backend%20Setup%20Directions.md).  There are [a variety of options](https://stackoverflow.com/questions/9843609/view-markdown-files-offline) for viewing .md files offline.
4. Refer to the Trello board for items tagged as "Frontend" (the blue bar) for pages to work on developing.  You can also choose your own page to work on (see "Choosing a page to work on").
5. Once you've edited a page you can view it by navigating to its route.  You may have to restart the server if you added images in developing the page. (Use `CTRL + C` to stop the server and `rails s` to start it again).
6. Each time you finish an idea's worth of work you should commit your changes to version control.  Commit early, commit often.  Also see [when to commit code](https://programmers.stackexchange.com/questions/83837/when-to-commit-code) and [how often to make commits](https://programmers.stackexchange.com/questions/74764/how-often-should-i-do-you-make-commits).  You want to push your commits to a branch.

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
