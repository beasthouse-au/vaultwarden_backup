> This is just a fork from [jmqm/vaultwarden_backup](https://github.com/jmqm/vaultwarden_backup) with some personal changes

---

Backs up vaultwarden files and directories to `tar.xz` archives automatically. `tar.xz` archives can be opened using data compression programs like [7-Zip](https://www.7-zip.org/) and [WinRAR](https://www.win-rar.com/).

Files and directories that are backed up:

- db.sqlite3
- config.json
- rsa_key.der
- rsa_key.pem
- rsa_key.pub.der
- /attachments
- /sends

## Usage

#### Automatic Backups

Refer to the `docker-compose` section below. By default, backing up is automatic.

#### Manual Backups

Pass `manual` to `docker run` or `docker-compose` as a `command`.

#### How to restore

1. Stop the application
1. Go to the *data* directory of **your** application ex. `cd /vaultwarden/data` (if that is my data folder)
1. Delete the db.sqlite3-wal `rm db.sqlite3-wal` (you dont need it since the backup was created using `.backup`)
1. Just extract `tar -xavf <backup-file.tar.xz>`
1. Run the application

You can read more in [the oficial wiki][how-restore]

## docker-compose

```
services:
  # vaultwarden configuration here if you want share the docker-compose file
  backup:
    image: ghcr.io/fabricionaweb/vaultwarden_backup
    network_mode: none
    # user: "1000:1000"                      # PUID:PGID (change if necessary)
    environment:
      - TZ=Europe/London                     # Timezone inside container
      - CRON_TIME=0 */24 * * *               # Runs at every day 00:00
      - DELETE_AFTER=30                      # Days to delete
    volumes:
      - /vaultwarden_data_directory:/data:ro # The Vaultwarden data directory to backup
      - /backup_directory:/backups           # Directory to save the backups
```

## Volumes _(permissions required)_

- `/data` _(read)_ - Vaultwarden's `/data` directory. Recommend setting mount as read-only.
- `/backups` _(write)_ - Where to store backups to.

## Environment Variables

| Environment Variable | Info                                                                                                     |
| -------------------- | -------------------------------------------------------------------------------------------------------- |
| CRON_TIME            | When to run _(default is every 12 hours)_. Info [here][cron-format-wiki] and editor [here][cron-editor]. |
| DELETE_AFTER         | Delete backups _X_ days old. Requires `read` and `write` permissions.                                    |

[cron-format-wiki]: https://www.ibm.com/docs/en/db2oc?topic=task-unix-cron-format
[cron-editor]: https://crontab.guru/
[how-restore]: https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault#restoring-backup-data
