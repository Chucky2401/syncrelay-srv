# Setup a red prompt for root and a green one for users.
# Symlink this file to color_prompt.sh to actually enable it.

_normal=$'\e[0m'
if [ $(id -u) = 0 ]; then
        _color=$'\e[1;31m'
        _symbol='#'
else
        _color=$'\e[1;32m'
        _symbol='$'
fi
if [ -n "$ZSH_VERSION" ]; then
        PS1="%{$_color%}%m [%{$_normal%}%~%{$_color%}]$_symbol %{$_normal%}"
else
        PS1="\[$_color\]\h [\[$_normal\]\w\[$_color\]]$_symbol \[$_normal\]"
fi
unset _normal _color _symbol
