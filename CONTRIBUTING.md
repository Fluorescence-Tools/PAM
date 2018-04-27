How to contribute to PAM
==========================

Did you find a bug? Run into an error?
-----------------------------------------

* **Check that you are on the newest version of the code.**
    * If you are on the *master* branch, check whether the problem has been resolved on the *develop* branch.
* **Ensure the bug was not already reported** by searching the [Issues](https://gitlab.com/PAM-PIE/PAM/issues) on GitLab.
* If you did not find an open issue relating to your problem, [open a new issue](https://gitlab.com/PAM-PIE/PAM/issues/new).
    * Make sure that you use a **clear title and description** of your problem.
    * Include as much relevant information as possible, e.g. what did you do that caused the problem?
    * Post the **error message**.
    
Did you fix a bug?
--------------------

* For **small and obvious bug fixes** (i.e. syntax errors, typos), [open a new issue](https://gitlab.com/PAM-PIE/PAM/issues/new),
    describing what the bug is and how to fix it.
    * These small bugfixes may be directly performed on the *develop* branch, however since the *develop* branch is protected, 
        a user with 'master' status has to perform the changes.

* For **larger bugfixes**, create a *bugfix* branch from *develop* to work on fixing a particular issue. Choose a **clear name** for the branch.
    * Work on fixing the bug, while keeping you branch **up-to-date** with the *develop* branch (see below).
    * Once the bug is fixed on your *bugfix* branch, submit a [merge request](https://gitlab.com/PAM-PIE/PAM/merge_requests/new) detailing you changes and await approval/feedback.

##### How do I create a branch?

* To create a branch for bugfixes, first make sure that you are on the *develop* branch by typing `git checkout develop`.
* Create a new branch from develop for your bugfix by typing `git checkout -b bugfix`. This will create the branch *bugfix* and switch to it. 
    * `git checkout -b bugfix` is equivalent to typing `git branch bugfix` + `git checkout bugfix`.
* Work on your bugfix and commit locally.
* To push your branch and commits to the remote, type `git push origin bugfix`.

##### How do I keep my branch up-to-date?

* To keep your branch up-to-date with changes to the *develop* branch of the remote repository:
    * Switch to your local *develop* branch, `git checkout develop`.
    * Update your local *develop* branch, `git pull`.
    * Switch back to you branch, `git checkout bugfix`.
    * Merge the changes to the *develop* branch into your *bugfix* branch, `git merge develop`.
* To integrate your changes into the *develop* branch of the *PAM* repository, open a [merge request](https://gitlab.com/PAM-PIE/PAM/merge_requests/new).

Do you want to work on a larger feature or addition to PAM?
-------------------------------------------------------------

* Follow the same workflow as for bugfixes by creating a *feature* branch. Choose a **clear name** for your *feature* branch. 
* Work on your feature, while keeping you branch up-to-date with the *develop* branch.
* Once your feature is finished, submit a merge request.

Don't want to make your code publicly available (yet)?
--------------------------------------------------------

Sometimes it might make sense to work on a new feature privately for a while. This is also possible! What you have to do is:
* Create a remote private PAM repository as a duplicate of the remote public PAM repository.
* Create a local repository from it.
* Add the remote public PAM repository to it as a second remote.

### Preparations
* Ensure PAM is working properly on your PC. 
* Ensure that you push and pull changes from GitLab.
    * If you are using the `https`protocol, you will need your GitLab username and password. 
    * If you are using the `git` protocol, ensure you have the proper SSH key for your device installed (i.e. you can pull and push changes).

### Creating a remote private PAM repository
* Create a fork from the public PAM repository. This is possible on https://gitlab.com/PAM-PIE/PAM, just click the Fork button in the row below the logo. Fork to a private repo belonging to your account.
* You now have a copy of the current state of PAM that is in a private repository on your account.
* Make sure you change the settings of this project to Private, not Public

### Creating your local private PAM repository
* Go to the base folder in which you want to create the new local repository. 
* Clone this locally as you do with PAM, e.g.: `!git clone https://gitlab.com/jellehendrix/PAM.git give-a-name`
* go to e.g. the develop branch: `!git checkout develop`
* To bring in the new updates others are making to the public PAM (you are now disconnected from that repository), add the original PAM repository as a second remote to your fork.
    * If your are using the `git` protocol: `!git remote add original git@gitlab.com:PAM-PIE/PAM.git`
    * If you are using the `https` protocol: `!git remote add original https://gitlab.com/PAM-PIE/PAM.git`
* You can list the registered remotes to your local repository by: `!git remote -v`

### Pulling from the remote public PAM repository to integrate the newest changes
Do this to get the latest changes from the public version of PAM
* `!git pull original develop`
* If you get something like "Host key verification failed." and you're sure your SSH key setting are ok, try switching to the `https` protocol instead by changing the URL of the remote *original*:
    * `!git remote set-url original https://gitlab.com/PAM-PIE/PAM.git`
* If files become changed after the pull, you need to add, commit and push them to the origin remote:
    * Stage the changes:    
        * `!git add file1 file2 file3` (add specific files)
        * or
        * `!git add .` (adds all files in folder, keep in mind that it will then also add files that were previously not tracked, i.e. if you have some custom scripts that shouldn't be on the repo)
    * `!git status` (tells which changes are staged for the commit, and which are not)
    * Commit the changes: `!git commit -m "comment on your commit"`
    * `!git push origin develop`
    * Notice: `!git push` will do the same if you want to push from develop to origin/develop (origin is the default remote name, and it will push by default to a branch with the same name as the local), but it is still advised to type the full command to avoid confusion! 
* You can list the registered remotes to your local repository by: `!git remote -v`

### Pulling from the remote private PAM repository
Do this when you start Matlab and before making any changes locally to synchronize your repository with the remote. This is important if you work privately on the new feature with other people on the same repository.
* `!git pull origin develop`

### Pushing to the remote private PAM repository
* Stage the changes:
    * `!git add file1 file2 file3` (add specific files)
    * or
    * `!git add .` (adds all, keep in mind that it will then also add files that were previously not tracked, i.e. if you have some custom scripts that shouldn't be on the repo)
* `!git commit -m "comment on your commit"`
* `!git push origin develop`

You now have a workflow to implement your changes in a private repository, and still keep up-to-date with the original PAM.

### Merging the private and public PAM remote
Once you are done and want to implement your changes into the public PAM, you need to push to a separate branch in the public PAM and then merge with develop or master. Please inquire with the Owner or a Master to do so!

