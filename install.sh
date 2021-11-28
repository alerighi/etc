#!/bin/sh

set -xe

for f in $PWD/bin/*; do
	ln -sf --backup "$f" "${HOME}/.local/bin"
done

ln -sf --backup "${PWD}/config/zshrc" "${HOME}/.zshrc"
ln -sf --backup "${PWD}/config/vimrc" "${HOME}/.vimrc"
ln -sf --backup "${PWD}/config/bashrc" "${HOME}/.bashrc"
