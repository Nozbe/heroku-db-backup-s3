#!/bin/bash

PYTHONHOME=/app/vendor/awscli/
DBNAME=""
EXPIRATION="30"
Green='\033[0;32m'
EC='\033[0m' 
FILENAME=`date +%Y%m%d_%H_%M`

# terminate script on any fails
set -e

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -exp|--expiration)
    EXPIRATION="$2"
    shift
    ;;
    -db|--dbname)
    DBNAME="$2"
    shift
    ;;
esac
shift
done

if [[ -z "$DBNAME" ]]; then
  echo "Missing DBNAME variable"
  exit 1
fi
if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
  echo "Missing AWS_ACCESS_KEY_ID variable"
  exit 1
fi
if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "Missing AWS_SECRET_ACCESS_KEY variable"
  exit 1
fi
if [[ -z "$AWS_DEFAULT_REGION" ]]; then
  echo "Missing AWS_DEFAULT_REGION variable"
  exit 1
fi
if [[ -z "$S3_BUCKET_PATH" ]]; then
  echo "Missing S3_BUCKET_PATH variable"
  exit 1
fi
if [[ -z "$DBURL_FOR_BACKUP" ]]; then
  echo "Missing DBURL_FOR_BACKUP variable"
  exit 1
fi
if [[ -z "$DB_BACKUP_ENC_KEY" ]]; then
  echo "Missing DB_BACKUP_ENC_KEY variable"
  exit 1
fi

printf "${Green}Start dump${EC}"
# Maybe in next 'version' use heroku-toolbelt
# /app/vendor/heroku-toolbelt/bin/heroku pg:backups capture $DATABASE --app $HEROKU_TOOLBELT_APP
# BACKUP_URL=`/app/vendor/heroku-toolbelt/bin/heroku pg:backups:public-url --app $HEROKU_TOOLBELT_APP | cat`
# curl --progress-bar -o /tmp/"${DBNAME}_${FILENAME}" $BACKUP_URL
# gzip /tmp/"${DBNAME}_${FILENAME}"

time pg_dump $DBURL_FOR_BACKUP | gzip | openssl enc -aes-256-cbc -e -pass "env:DB_BACKUP_ENC_KEY" >  /tmp/"${DBNAME}_${FILENAME}".gz.enc

#EXPIRATION_DATE=$(date -v +"2d" +"%Y-%m-%dT%H:%M:%SZ") #for MAC
EXPIRATION_DATE=$(date -d "$EXPIRATION days" +"%Y-%m-%dT%H:%M:%SZ")

printf "${Green}Move dump to AWS${EC}"
time /app/vendor/awscli/bin/aws s3 cp /tmp/"${DBNAME}_${FILENAME}".gz.enc s3://$S3_BUCKET_PATH/$DBNAME/"${DBNAME}_${FILENAME}".gz.enc --expires $EXPIRATION_DATE

# cleaning after all
rm -rf /tmp/"${DBNAME}_${FILENAME}".gz.enc
