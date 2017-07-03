 zHow to contribute to PAM
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
    * Work on fixing the bug, while keeping you branch **up-to-date** with the *develop* branch.
    * Once the bug is fixed on your *bugfix* branch, submit a [merge request](https://gitlab.com/PAM-PIE/PAM/merge_requests/new) detailing you changes and await approval/feedback.

### How do I create a branch?

* To create a branch for bugfixes, first make sure that you are on the *develop* branch by typing `git checkout develop`.
* Create a new branch from develop for your bugfix by typing `git checkout -b bugfix`. This will create the branch *bugfix* and switch to it. 
*   * `git checkout -b bugfix` is equivalent to typing `git branch bugfix` + `git checkout bugfix`.
* Work on your bugfix and commit locally.
* To push your branch and commits to the remote, type `git push origin bugfix`.
* Open a [merge request](https://gitlab.com/PAM-PIE/PAM/merge_requests/new).

Do you want to work on a larger feature or addition to PAM?
-------------------------------------------------------------

* Follow the same workflow as for bugfixes by creating a *feature* branch. Choose a **clear name** for your *feature* branch. 
* Work on your feature, while keeping you branch up-to-date with the *develop* branch.
* Once your feature is finished, submit a merge request.