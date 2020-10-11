#!/bin/sh

set -xe

for f in bin/*; do
	install -m 700 "$f" "${HOME}/.local/bin"
done

install -m 600 config/zshrc "${HOME}/.zshrc"
install -m 600 config/vimrc "${HOME}/.vimrc"
