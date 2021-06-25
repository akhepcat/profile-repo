# profile-repo
Clean-room profile management building blocks


The three main files are broken into:
	* bash_inputrc
	* bash_profile
	* bash_aliases

the remaining file is a very simple install script that must be run from the repo diretory.

Once installed, things will look like this:

	lrwxrwxrwx   1 user user          30 Nov 13 16:15 .bash_aliases -> src/profile-repo/bash_aliases
	lrwxrwxrwx   1 user user          30 Nov 13 16:15 .bash_login -> src/profile-repo/bash_profile
	lrwxrwxrwx   1 user user          30 Nov 19 08:24 .bash_profile -> src/profile-repo/bash_profile
	lrwxrwxrwx   1 user user          11 Nov 13 16:20 .bashrc -> src/profile-repo/bash_profile
	lrwxrwxrwx   1 user user          11 Nov 13 16:20 .profile -> src/profile-repo/bash_profile
	lrwxrwxrwx   1 user user          32 Mar 18 09:40 .inputrc -> src/profile-repo/bash_inputrc


existing versions are moved to  _local  variations, or the script dies when it can't resolve conflict issues
