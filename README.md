# redis-backup-gcs

Create a backup of a specified redis db to Google Cloud Storage

## Configuration

Set the following environment variables for the Docker container:

`REDIS_HOST` Hostname of redis db

`REDIS_PORT` Port of redis db

`REDIS_PASSWORD` Password of redis db

`GCS_BUCKET_REDIS` Google Cloud Storage bucket name

`BACKUP_NAME` Name of the backup file, will be appended by the current date

`GOOGLE_APPLICATION_CREDENTIALS` Path to mounted credentials file (google service account key json file)
