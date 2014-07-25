#!/bin/bash

MAINPATH="/srv/craftbukkit-1.7.2"
BACKUPPATH="/srv/craftbukkit-1.7.2/backup"
WORLDPATH="/srv/craftbukkit-1.7.2/world"

USER="$2"
SESSION="$3"

if [ -z $2 ]; then
        USER="craftbukkit"
fi

if [ -z $3 ]; then
	SESSION="craftbukkit-172-console"
fi

save_stop() {
    sudo -u ${USER} tmux send-keys -t ${SESSION} 'save-off' C-m
    sudo -u ${USER} tmux send-keys -t ${SESSION} 'save-all' C-m
}

save_start() {
    sudo -u ${USER} tmux send-keys -t ${SESSION} 'save-on' C-m
}

case "$1" in
  start)
    if ! sudo -u ${USER} tmux has -t ${SESSION}; then
      sudo -u ${USER} tmux new-session -d -s ${SESSION} -d "cd ${MAINPATH}; java -Xmx1024M -Xms1024M -jar ${MAINPATH}/craftbukkit.jar nogui"
      if [ $? -gt 0 ]; then
        exit 1
      fi
    else
      echo "Craftbukkit already started"
      exit 1
    fi
    ;;

  stop)
    sudo -u ${USER} tmux send-keys -t ${SESSION} 'broadcast NOTICE: Server shutting down in 5 seconds!' C-m
    sleep 5
    sudo -u ${USER} tmux send-keys -t ${SESSION} 'stop' C-m
    sleep 10
    ;;

  console)
    sudo -u ${USER} tmux attach -t ${SESSION}
    ;;
  
  backup)
    echo "Starting backup"
    FILE="`date +%Y%m%d%H%M`.tar.gz"
    path="$BACKUPPATH/$FILE"
    su -s /bin/bash -c "mkdir -p $BACKUPPATH" ${USER}
    save_stop
    su -s /bin/bash -c "tar -czf $path $WORLDPATH" ${USER}
    save_start
    echo "Backup finished"
    ;;

  *)
    echo "usage: $0 {start|backup|console} user"
esac

exit 0

