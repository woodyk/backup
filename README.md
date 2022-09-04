# backups
Simple incremental backup script used for multi-server backups.

## Note
> You must prepare your hosts for rsync over ssh.  Besure to share the appropriate ssh keys between the backup source and destination.

## Edit backups.sh variables.
Edit the backups.sh file and your paths to the required variables.
```
RSYNC="/usr/bin/rsync"
DPOINT="/backups"
CONF="/etc/backups.conf"
LOGGER="logger -i -t backup.sh"
RSYNC_USER="root"

# Number of snapshots to retain
SNAPSHOTS=7
```

## Populate your backups.conf file.
The appropriate syntax is:
```
hostname:/path1,/path2,...
```
eg.
```
webserver.local:/etc/apache2,/home,/var/www
```

