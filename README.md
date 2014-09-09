rsync-backup
============

**Client-side only** tools to automate incremental backups with `rsync`.

It uses `hard links` to create each incremental backup.

Only files that are different from last incremental backup are sent and stored.

Thanks to hard link magic, each incremental backup seems just like a full backup, although it takes space only for changed files.

Thanks to hard link magic again, merging the backup with next one is done by just removing the previous backup completely. You can do this manually or let my script do it for you.

Don't try to backup to filesystem that doesn't support hard links. Maybe it'll create full backup every time, maybe it'll just explode an error to your face. I don't know.

I have tested only local and ssh backups.

Features
========

An incredible amount of features are available, including only:

 * Incremental backups using hard links
 * Backup rotations
 * SystemD and cron support

Installation
============

No configuration and installation is required on server-side, except the obvious ones:

 * ssh daemon up and running,
 * a fairly modern rsync installed (>= 2.6.4)
 * filesystem that supports hard links

If your system uses SystemD, you'll probably want to install SystemD unit files only.
Otherwise you're forced to use good old cron.

SystemD
-------

    make install-systemd

Cron
----

    make install-cron

Usage
=====

SystemD
-------

The configuration is saved to `/etc/default/backup@example` by default.
You should check it out, it's well documented.

To start the timer (what cronjob used to be):

    systemctl start backup@example.timer

To automatically start the timer at each boot:

    systemctl enable backup@example.timer

To manually start backup once:

    systemctl start backup@example.service

To view logs:

    systemctl status backup@example.service

Cron
----

The configuration is saved to `/etc/default/backup` by default.
You should check it out, it's well documented.

To manually start backup once:

    . /etc/default/backup && /usr/bin/backup

You'll probably want to do that in sub-shell, to avoid your environment variables get screwed.
For example, in bash you can do this:

    ( . /etc/default/backup && /usr/bin/backup )


Other things should be self-explanatory.


Tips and tricks
===============

To speed up things a bit you can use something like this in your config file:

    ssh="ssh -o Ciphers=arcfour128,arcfour256,arcfour,aes128-cbc,blowfish-cbc -o MACs=umac-64@openssh.com,hmac-md5-96,hmac-md5"

If you want to backup some mounted filesystems as well, remove the `-x` option from params and add `--exclude` parameters if needed. Also, you can remove the `-S` option and add `--inplace` for more performance gains, but less efficiently stored big files. Something like this:

    params="-azXAHE --inplace --exclude={'/dev/*','/proc/*','/sys/*','/tmp/*','/run/*','/mnt/*','/media/*','/lost+found'}"

I'm also not sure if `-z` does anything besides frying CPU.


Responsibility
=============

Use this on your own responsibility. I do not care if your computer explodes, your wife cheats on you or you die from heart attack when you found out that all your files are gone while you use this script. Test it first. You have been warned.
