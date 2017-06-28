PAM - PIE Analysis with MATLAB 
=================================

The program can be downloaded from the homepage of Prof. Don C. Lamb - http://www.cup.uni-muenchen.de/pc/lamb/ - or through *GitLab* - https://gitlab.com/PAM-PIE.

This *GitLab* group contains frour projects:

* **PAM:** The open-source version of PAM used with MATLAB.
* **PAMcompiled:** A compiled stand-alone version that does not require MATLAB.
* **PAM-sampledata:** Some example data the user can use to try out the PAM functionalities.
* **PAMdocs:** Project that contains files for the delevopers to update the PAM documentation and manual.

Installing the stand-alone version of PAM
=========================================

1. Verify the correct MATLAB Runtime is installed (currently v9.1/ Matlab 2016b).

    You can download the MATLAB Runtime from the MathWorks Web site by navigating to 

    http://www.mathworks.com/products/compiler/mcr/index.html
    
    For more information about the MATLAB Runtime and the MATLAB Runtime installer, see 
    [Package and Distribute](https://de.mathworks.com/help/compiler_sdk/package.html) in the MATLAB Compiler documentation in the MathWorks Documentation Center.   

2. Download the compiled version of PAM for your Operating system (MacOS or WIN) from

    https://gitlab.com/PAM-PIE/PAMcompiled

3. Unpack the files.

4. Run the *PAM.exe* (Windows) or *run_PAM.command* (MacOS) to start the program. For MacOS, consult the *readme.txt* and *how_to_create_shortcut.txt* for additional information.


Installing and updating the open-source version of PAM
========================================================

The open source version of PAM requires a valid licence for MATLAB (2014b or newer).
Certain features further need access to tool boxes (curve fitting, image processing, statistics and machine learning, parallel computing) to work.

You can obtain and update **PAM** either through direct download from *Gitlab*, using the command line through *Git*, or by using the MATLAB *Git* integration.

Downloading from the repository
---------------------------------

1. Download the open source version of PAM from https://gitlab.com/PAM-PIE/PAM
2. Unpack the files.
3. Start Matlab and navigate to the PAM folder.
4. Type `PAM` into the Matlab command line to start the program.
5. To update, simply download the newest version and overwrite your files.

Using Git
-------------

### Installing Git

Updating of **PAM** requires the installation of *Git*.

* **MacOS:**

    MacOS has *Git* pre-installed since version 10.9. Try to run `git` from the terminal. If the command fails, you can download *Git* from https://git-scm.com.

* **Windows:**

    Download and install *Git* from https://git-for-windows.github.io.

### Downloading and updating using Git

* To clone the repository, type `git clone https://gitlab.com/PAM-PIE/PAM.git PAM` to create a local copy of the repository in the folder PAM.
    * By default, you are checkout on the branch *master*, containing the stable version of **PAM**.
    * Should you need the newest updates, switch to the *develop* branch by typing `git checkout develop`.
    * To switch back, type `git checkout master`.
* To update, simply type `git pull` to obtain the newest changes. Note that this will only update the branch that you are currently on.

Via MATLAB Git Integration
------------------------

To use all features of the MATLAB *Git* integration, it is recommended to install *Git* as described above.

1. Create a folder for PAM.
2. Start Matlab and navigate to the PAM folder.
3. Right click the 'Current Folder' panel in Matlab and select 'Source Control' and 'Manage Files...'.
4. Set the 'Source control integration' to 'Git' and enter for the 'Repository path' https://gitlab.com/PAM-PIE/PAM.git.
5. Click 'Retrieve' to download the files automatically.
6. To update the PAM Git repository to the latest version, simply type `!git pull` into the MATLAB command line.

To update, you can alternatively use the MATLAB *Git* integration, however the `!git pull` method is easier and quicker.

1. Right click the 'Current Folder' panel in Matlab and select 'Source Control' and 'Fetch'.
2. Right click the 'Current Folder' panel in Matlab and select 'Source Control' and 'Manage Branches'.
3. Select the current branch form the remote repository, called 'origin'.
    If you work on branch *master*, select *origin/master* (or *refs/remotes/origin/master*).
4. Click 'Merge' to merge the changes from the remote into you local repository.

Modification and development of PAM
======================================

Users are encouraged to modify the code of PAM for their individual needs
and help with the development of new and the improvement of existing functionalities.

To report bugs or suggest improvements and bugfixes, please use the 'Issues' function of GitLab.
For this, a free GitLab account is required.

To contribute to PAM, please consult the *contribution guide*.
