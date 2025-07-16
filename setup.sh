#!/bin/bash

# Install oh my zsh with plugins if it's not there
configure_zsh() {
	echo "installing oh my zsh"
	
	# don't let the shell change / auto-launch
	export RUNZSH=no
	export CHSH=no
	
	sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

	# clone in the plugins
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

}

# stow dotfiles
stow_configs() {
	# ensure that we're in the correct working directory
	cd "$HOME/.dotfiles"


	# exclude setup files and check if perms needed
	EXCLUDES=(".git" "setup.sh" ".oh-my-zsh")
	NEEDS_ROOT=("fonts" "themes" "icons") 

	for pkgdir in */; do
		pkg="${pkgdir%/}"

		# skip .git and setup file
		if [[ " ${EXCLUDES[*]} " == *" $pkg "* ]]; then
			echo "Skipped $pkg"
			continue
		fi

		echo "Stowing $pkg"

		if [[ " ${NEEDS_ROOT[*]} " == *" $pkg "* ]]; then
			su -c "stow --adopt -v -t / \"$pkg\""
		else
			stow -v "$pkg"
		fi
	
	done

}

# if oh my zsh isn't installed, run the zsh function
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	configure_zsh

	# delete .zshrc file that omz generates
	rm $HOME/.zshrc
fi

stow_configs


