#!/bin/bash

set -eo pipefail

if [ -z $REDIS_HOST ] ; then
    echo "You must specify a REDIS_HOST env var"
    exit 1
fi
if [ -z $REDIS_PORT ] ; then
    echo "You must specify a REDIS_PORT env var"
    exit 1
fi
if [ -z REDIS_PASSWORD ] ; then
    echo "You must specify a REDIS_PASSWORD env var"
    exit 1
fi

if [ -z $GCS_BUCKET_REDIS ]; then
    echo "You must specify a google cloud storage GCS_BUCKET_REDIS address such as gs://my-backups/"
    exit 1
fi

if [ -z $BACKUP_NAME ]; then
    BACKUP_NAME=redis_backup
fi

CURRENT_DATE=$(date -u +"%Y-%m-%dT%H%M%SZ")
BACKUP_SET="$BACKUP_NAME-$CURRENT_DATE.rdb"

echo "Activating google credentials before beginning"
gcloud auth activate-service-account --key-file "$GOOGLE_APPLICATION_CREDENTIALS"

if [ $? -ne 0 ] ; then
    echo "Credentials failed; no way to copy to google."
    echo "Ensure GOOGLE_APPLICATION_CREDENTIALS is appropriately set."
fi

echo "=============== Redis Backup ==============================="
echo "Beginning backup from $REDIS_HOST to /backup/$BACKUP_SET"
echo "To google storage bucket $GCS_BUCKET_REDIS using credentials located at $GOOGLE_APPLICATION_CREDENTIALS"
echo "============================================================"

redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} -a ${REDIS_PASSWORD} --rdb "/backup/dump.rdb"

ls -al "/backup"
echo "Backup size:"
du -hs "/backup/dump.rdb"

echo "Tarring -> /backup/$BACKUP_SET.tar"
tar -xzvf "/backup/$BACKUP_SET.tar.gz" "/backup/dump.rdb"

echo "Zipped backup size:"
du -hs "/backup/$BACKUP_SET.tar.gz"

echo "Pushing /backup/$BACKUP_SET.tar.gz -> $GCS_BUCKET_REDIS"
gsutil cp "/backup/$BACKUP_SET.tar.gz" "$GCS_BUCKET_REDIS"

echo "Redis backups ended"
exit $?
