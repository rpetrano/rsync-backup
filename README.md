rsync-backup
============

Client-side tools to automate incremental backups with rsync over ssh.

No configuration and installation is required on server-side, except the obvious ones:
 * ssh daemon up and running,
 * a fairly modern rsync installed (>= 2.6.4)

Features
========

An incredible amount of features is available, including:
 * Incremental backups
 * Backup rotations
 * SystemD integration
