app.service('helpFactory', function($timeout) {
    var factory = this;

    this.introduction = 'Hi, I am the Mod Picker helper.  I provide information about the page you\'re currently viewing with links to the <a href="/help" target="_blank">Mod Picker Help Center</a> to learn more.  You can disable me by default from your <a href="settings">user settings</a>.';

    this.error = 'Sorry, an error happened when loading help messages for this page.  Please try <a href="javascript:location.reload();">reloading the page</a>!';

    this.welcome = 'Welcome to the Mod Picker Beta!  Check out the <a href="article/1">Welcome Article</a> for help getting started using the site.';

    this.home = 'This is the Mod Picker home page.  You can view site news and recent contributions here.  <a href="/help/home_page" target="_blank">Click here</a> for more information.';

    this.modsIndex = 'This is the mods index, where you can browse for mods on Mod Picker.  <a href="/help/mods_index" target="_blank">Click here</a> for more information.';

    this.indexPage = 'This is an index page, where you can browse content on Mod Picker.  <a href="/help/index_pages" target="_blank">Click here</a> for more information.';

    this.notifications = 'These is an archive of all notifications you\'ve recieved while a user on Mod Picker.  <a href="/help/notifications" target="_blank">Click here</a> for more information.';

    this.article = 'This is an article - an official posting by the Mod Picker site staff.  It\'s good to keep up to date by reading these!  <a href="/help/articles" target="_blank">Click here</a> for more information.';

    this.submitMod = 'This is the submit mod page.  You can hover your mouse over the question marks for hints on each section.  <a href="/help/mod_submission" target="_blank">Click here</a> for more information.';

    this.editMod = 'This is the edit mod page.  Here you can change the mod\'s attributes and update its analysis.  <a href="/help/edit_mod_page" target="_blank">Click here</a> for more information.';

    this.modCollection = 'This is another user\'s mod collection.  If you like this collection you can add it to your active mod list.  <a href="/help/mod_collections" target="_blank">Click here</a> for more information.';

    this.modList = 'This is another user\'s mod list.  <a href="/help/mod_list_page" target="_blank">Click here</a> for more information.';

    this.editModList = 'This is the mod list page.  You can edit this mod list by clicking the "Edit" button.  <a href="/help/mod_list_page" target="_blank">Click here</a> for more information.';

    this.activeModList = 'This is your <a href="/help/mod_list_page" target="_blank">active mod list</a>.  Added mods or collections from other parts of the site will go into this mod list.  You can change your active mod list from your <a href="settings">settings</a>, or by editing a different mod list.';

    this.userSettings = 'This is your user settings page.  Here you can adjust how you use the site, link accounts, change themes, and more.  <a href="/help/user_settings" target="_blank">Click here</a> for more information.';

    this.userProfile = 'This is a user\'s profile page.  You can get an idea of what a user has contributed to Mod Picker here.  <a href="/help/user_profile_page" target="_blank">Click here</a> for more information.';

    this.yourProfile = 'This is your profile page.  You can edit what is displayed here from your <a href="settings">user settings</a> page.  <a href="/help/user_profile_page" target="_blank">Click here</a> for more information.';

    this.mod = 'This is a mod page which displays information and contributions for a mod on Mod Picker.  <a href="/help/mod_page" target="_blank">Click here</a> for more information.';

    this.userProfileContext = function(isCurrentUser) {
        return isCurrentUser ? [factory.yourProfile] : [factory.userProfile];
    };

    this.homeContext = function(currentUser) {
        return currentUser.sign_in_count > 2 ? [factory.home] : [factory.welcome];
    };

    this.modListContext = function(modList, canManage, isActive) {
        if (canManage) {
            return isActive ? [factory.activeModList] : [factory.editModList];
        } else {
            return modList.is_collection ? [factory.modCollection] : [factory.modList];
        }
    };

    this.setHelpContexts = function($scope, contexts) {
        $timeout(function() {
            $scope.$emit('setHelpContexts', contexts);
        }, 200);
    };
});