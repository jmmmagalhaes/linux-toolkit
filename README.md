# Alberon Linux toolkit

Useful scripts for maintaining Linux servers.

## Setup

As root:

```bash
cd
git clone git@github.com:alberon/linux-toolkit.git alberon-linux-toolkit
```

Then just run the scripts you need.

## Scripts

Script                                  | Description
----------------------------------------|-------------
`cron-list.sh`                          | List all cron jobs for all users ([source](http://stackoverflow.com/a/137173))
`reload-cron.sh`                        | Tell Cron to reload the config files in ./cron.d/ (inotify doesn't watch symlink targets)
***Composer***                          |
`composer-install.sh`                   | Install Composer, optionally install cron job to keep it updated
`composer-uninstall.sh`                 | Uninstall Composer and cron job
`composer-upgrade.sh`                   | Manually upgrade Composer
`cron-upgrade-composer-install.sh`      | Install cron job to upgrade Composer daily
`cron-upgrade-composer-uninstall.sh`    | Remove cron job
***Forward System Mail***               |
`forward-system-mail.sh`                | Set up a mail forwarder for all user accounts to catch bounces and alerts
`cron-forward-system-mail-install.sh`   | Install hourly cron job for mail forwarder
`cron-forward-system-mail-uninstall.sh` | Remove cron job

## Also see

- [Check MX records](https://github.com/alberon/check-mx-records) - for historical reasons this is in a separate repository
