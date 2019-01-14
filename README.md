# Alberon Linux toolkit

Useful scripts for maintaining Linux servers.

## Setup

As root:

```bash
cd /root
git clone git@github.com:alberon/linux-toolkit.git alberon-linux-toolkit
alberon-linux-toolkit/cron-install.sh
```

## Scripts

Script                                  | Description
----------------------------------------|-------------------------------------------------------------------------------------------
***Cron***                              |
`cron-install.sh`                       | Interactively install cron jobs
`cron-list.sh`                          | List all cron jobs for all users ([source](http://stackoverflow.com/a/137173))
`cron-uninstall.sh`                     | Interactively remove cron jobs
`reload-cron.sh`                        | Tell Cron to reload the config files in ./cron.d/ (inotify doesn't watch symlink targets)
***Composer***                          |
`composer-install.sh`                   | Install Composer, optionally install cron job to keep it updated
`composer-uninstall.sh`                 | Uninstall Composer and cron job
`composer-upgrade.sh`                   | Manually upgrade Composer
`check-composer-security.sh`            | Checks all `composer.lock` files for known vulnerabilities at SensioLabs
***Other***                             |
`check-if-reboot-is-required.sh`        | Check if the system needs to be rebooted for a Kernel update
`check-large-error-logs.sh`             | Finds all `error_log` files ordered by size
`check-mx-records.php`                  | Checks if the cPanel is correctly set to Local/Remote email when using an external DNS server
`forward-system-mail.sh`                | Set up a mail forwarder for all user accounts to catch bounces and alerts

## `check-mx-records.php`

Check and report all results including successes:

```
check-mx-records/check-mx-records.php
```

Check and report only warnings and errors:

```
check-mx-records/check-mx-records.php -q
```

Check and report only errors (this is what cron uses):

```
check-mx-records/check-mx-records.php -qq
```

To ignore one or more domains, create a file `/etc/check-mx-records-ignore` and enter one domain per line.
