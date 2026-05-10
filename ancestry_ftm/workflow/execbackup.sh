#!/bin/sh

# MAIN SCRIPT TO LAUNCH THE FAMILY TREE MAKER BACKUP/DEPLOY PROCESS

# set location parameters:
ftmdir=/srv/arc/virtual_media/win11/shared/ftm
backsh=/srv/arc/dev/github_cmosher01/Gedcom-Misc/ancestry_ftm/workflow/backup.sh
logdir=/srv/arc/dev/github_cmosher01/family-tree-maker-data/sync_logs
gitdir=/srv/arc/dev/github_cmosher01/family-tree-maker-data
bakdir=/srv/arc/linode/backup/ftm
dstdir=/srv/arc/linode/ftm



logfile=$(date '+%Y%m%dT%H%M%S.log')
echo "cat $logfile"

cd $ftmdir
exec $backsh $bakdir $dstdir $gitdir >$logdir/$logfile 2>&1
