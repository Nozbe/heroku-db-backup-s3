## Heroku Buildpack: heroku-mysql-backup-s3
Capture Postgres or MySQL DB in Heroku and copy it to s3 bucket. Buildpack contains AWS CLI.

### Installation
Add buildpack to your Heroku app
```
heroku buildpacks:add https://github.com/plymouthsoftware/heroku-db-backup-s3 --app <your_app>
```
> Buildpacks are scripts that are run when your app is deployed.

### Configure environment variables
```
heroku config:add DB_BACKUP_AWS_ACCESS_KEY_ID=someaccesskey --app <your_app>
heroku config:add DB_BACKUP_AWS_SECRET_ACCESS_KEY=supermegasecret --app <your_app>
heroku config:add DB_BACKUP_AWS_DEFAULT_REGION=eu-central-1 --app <your_app>
heroku config:add DB_BACKUP_S3_BUCKET_PATH=your-bucket --app <your_app>
heroku config:add DB_BACKUP_ENC_KEY=somethingverysecret --app <your_app>
```
- In future release (maybe) will use heroku-toolbelt
```
heroku config:add HEROKU_TOOLBELT_APP=<your_app> --app <your_app>
heroku config:add HEROKU_TOOLBELT_API_EMAIL=sss --app <your_app>
heroku config:add HEROKU_TOOLBELT_API_PASSWORD=ddd --app <your_app>
```
For Postgres:

Go to settings page of your Heroku application and add Config Var `DBURL_FOR_BACKUP` with the same value as var `DATABASE_URL`. This is our DB connection string.

For MySQL:

heroku config:add DB_BACKUP_HOST=your-db-host --app <your_app>
heroku config:add DB_BACKUP_USER=your-db-user --app <your_app>
heroku config:add DB_BACKUP_PASSWORD=your-db-password --app <your_app>
heroku config:add DB_BACKUP_DATABASE=your-db-name --app <your_app>

### Scheduler
Add addon scheduler to your app.
```
heroku addons:create scheduler --app <your_app>
```
Create scheduler.
```
heroku addons:open scheduler --app <your_app>
```
Now in browser `Add new Job`.
Paste next line:
`bash /app/vendor/backup.sh -db <somedbname>`
and configure FREQUENCY. Paramenter `db` is used for naming convention when we create backups. We don't use it for dumping  database with the same name.

### Doesn't work?
In case if scheduler doesn't run your task, check logs using this e.g.:
```
heroku logs -t  --app <your_app> | grep 'backup.sh'
heroku logs --ps scheduler.x --app <you_app>
```
