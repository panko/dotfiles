# i only want tmux when i want it :)
if [ -z "$TMUX" ] && [ ${UID} != 0 ] && [ -z $SSH_CONNECTION ] && [ "$USER" = "prike" -o "$USER" = "zpnpate" ];
then
    tmux new-session -A -s main
fi
