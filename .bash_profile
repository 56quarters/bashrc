# no shebang

# This file is sourced by bash for login shells. The following line
# runs your .bashrc and is recommended by the bash info pages.
if [ -f "${HOME}/.bashrc" ]; then
    # shellcheck source=.bashrc
	. "${HOME}/.bashrc"
fi
