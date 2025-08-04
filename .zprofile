# i only want tmux when i want it :)
#if [ -z "$TMUX" ] && [ ${UID} != 0 ] && [ -z $SSH_CONNECTION ] && [ "$USER" = "prike" -o "$USER" = "workusernamehehe" ];
#then
#    tmux new-session -A -s main
#fi


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # ...
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
