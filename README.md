rsync-backup
============

Client-side tools to automate incremental backups with rsync over ssh.

No configuration and installation is required on server-side, except the obvious ones:
 * ssh daemon up and running,
 * a fairly modern rsync installed (>= 2.6.4)

Features
========

An incredible amount of features is available, including only:
 * Incremental backups
 * Backup rotations
 * SystemD integration
 * Bugs


SystemD
=======

Installation
------------

    install -o root -g root -m 700 src/backup.sh /usr/bin/backup
    install -o root -g root -m 600 src/example.conf /etc/default/backup@full
    install -o root -g root systemd/backup@.service /etc/systemd/system/
    install -o root -g root systemd/backup@.timer /etc/systemd/system/

Usage
-----

To start the timer (what cronjob used to be):

    systemctl start backup@full.timer

To automatically start the timer at each boot:

    systemctl enable backup@full.timer

To manually start backup once:

    systemctl start backup@full.service

To view logs:

    systemctl status backup@full.service

Cron
====

Installation
------------

    install -o root -g root -m 700 src/backup.sh /usr/bin/backup
    install -o root -g root -m 600 src/example.conf /etc/default/backup
    install -o root -g root cron/backup.crontab /etc/cron.d/

Usage
-----

To manually start backup once:

    . /etc/default/backup && /usr/bin/backup

Other things should be self-explanatory.


Tips and tricks
===============

To speed up things a bit you can use something like this in your config file:

    ssh="ssh -o Ciphers=arcfour128,arcfour256,arcfour,aes128-cbc,blowfish-cbc -o MACs=umac-64@openssh.com,hmac-md5-96,hmac-md5"

If you want to backup some mounted filesystems as well, remove the `-x` option from params and add `--exclude` parameters if needed. Also, you can remove the `-S` option and add `--inplace` for more performance gains, but less efficiently stored big files. Something like this:

    params=-avzXAHE --inplace --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"}

I'm also not sure if `-z` does anything besides frying CPU.


Responsibility
=============

Use this on your own responsibility. I do not care if your computer explodes, your wife cheats on you or you die from heart attack when you found out that all your files are gone while you use this script. Test it first. You have been warned.
