# dotfiles/home/.bash_logout ⮞ https://github.com/quackhack-mcblindy/dotfiles

# 🦆 says ⮞ when leaving the console clear the screen to increase privacy
if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi
