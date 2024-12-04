
if [ -z "$TMUX" ] && [ ${UID} != 0 ] && [ -z $SSH_CONNECTION ];
then
    tmux new-session -A -s main
fi
