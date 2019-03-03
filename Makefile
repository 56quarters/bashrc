#

.PHONY: test

test:
	shellcheck --shell bash .bashrc .bash_profile
