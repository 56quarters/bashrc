# no shebang
#

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

maybe_load() {
    local FILE="$1"
    if [ -f "$1" ]; then
        . "$1"
    fi
}

setup_ruby() {
    if [ -d "${HOME}/.gem" ]; then
        local RUBIES="$(ls -1 ${HOME}/.gem/ruby/)"
        for RUBY_VER in $RUBIES; do
            export PATH="${PATH}:${HOME}/.gem/ruby/${RUBY_VER}/bin"
        done
    fi
}

setup_rust() {
    if [ -d "${HOME}/.cargo/bin" ]; then
        export PATH="${PATH}:${HOME}/.cargo/bin"
    fi
}

setup_go() {
    if [ -n "$GOPATH" ]; then
        export PATH="${PATH}:${GOPATH}/bin"
    elif [ -d "${HOME}/go" ]; then
        export PATH="${PATH}:${HOME}/go/bin"
    fi
}

setup_local() {
    if [ -d "${HOME}/bin" ]; then
        export PATH="${PATH}:${HOME}/bin"
    fi

    if [ -d "${HOME}/.local/bin" ]; then
        export PATH="${PATH}:${HOME}/.local/bin"
    fi
}

setup_completions() {
    local _=$(which rustup 2> /dev/null)
    if [ $? -eq 0 ]; then
        . <(rustup completions bash)
    fi

    local _=$(which kubectl 2> /dev/null)
    if [ $? -eq 0 ]; then
        . <(kubectl completion bash)
    fi
}

setup_keychain() {
    local KEYCHAIN_SCRIPT="${HOME}/.keychain/$(hostname -s)-sh"
    if [ -f "$KEYCHAIN_SCRIPT" ]; then
        . "$KEYCHAIN_SCRIPT"

        local SSH_KEYS="$(ls -1 ${HOME}/.ssh/id_* | grep -v .pub)"
        keychain --quiet "$SSH_KEYS"
    fi
}

# Add various directories to our path
setup_ruby
setup_rust
setup_go
setup_local

setup_completions
setup_keychain

maybe_load "${HOME}/.bash_aliases"
maybe_load "${HOME}/.bash_prompt"
maybe_load "${HOME}/.extra"
