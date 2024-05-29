# no shebang

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

maybe_load() {
    local FILE="$1"
    if [ -f "$FILE" ]; then
        # shellcheck source=/dev/null
        . "$FILE"
    fi
}

setup_ruby() {
    if [ -d "${HOME}/.gem" ]; then
        for RUBY_VER in "${HOME}/.gem/ruby/"*; do
            export PATH="${PATH}:${RUBY_VER}/bin"
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

setup_pony() {
    if [ -d "${HOME}/.local/share/ponyup/bin" ]; then
        export PATH="${PATH}:${HOME}/.local/share/ponyup/bin"
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
    maybe_load "/usr/share/bash-completion/bash_completion"

    if command -v rustup > /dev/null; then
        # shellcheck source=/dev/null
        . <(rustup completions bash)
    fi

    if command -v kubectl > /dev/null; then
        # Set KUBECONFIG to /dev/null since otherwise the completion command
        # attempts to make network connections which results in it taking 1+
        # seconds instead of a few milliseconds. The resulting completion
        # code is nearly identical in both cases with only some superficial
        # differences.
        # shellcheck source=/dev/null
        . <(KUBECONFIG=/dev/null kubectl completion bash)
    fi
}

setup_keychain() {
    local OUR_HOST KEYCHAIN_SCRIPT SSH_KEYS;

    OUR_HOST="$(hostname -s)"
    KEYCHAIN_SCRIPT="${HOME}/.keychain/${OUR_HOST}-sh"

    if command -v keychain > /dev/null; then
        # Using maybe load here because the script doesn't exist before
        # keychain is run for the first time.
        maybe_load "$KEYCHAIN_SCRIPT"

        # We need to filter out public keys and hence need one result
        # per line and `ls -1` is the best way to do that, so make sc
        # stop complaining about it.
        # shellcheck disable=SC2010
        SSH_KEYS=$(ls -1 "${HOME}/.ssh/id_"* | grep -v .pub)
        keychain --quiet "$SSH_KEYS"
    fi
}

setup_colors() {
    if [ -x /usr/bin/dircolors ]; then
        if [ -f "${HOME}/.dir_colors" ]; then
            eval "$(dircolors -b "${HOME}/.dir_colors")"
        else
            eval "$(dircolors -b)"
        fi

        alias ls="ls --color=auto"
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    fi
}

_main() {
    # Add various directories to our path
    setup_ruby
    setup_rust
    setup_go
    setup_pony
    setup_local

    setup_completions
    setup_keychain
    setup_colors

    maybe_load "${HOME}/.bash_aliases"
    maybe_load "${HOME}/.bash_prompt"
    maybe_load "${HOME}/.extra"
}

_main "$@"
