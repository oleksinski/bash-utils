#!/usr/bin/env bash

_dbg=true
db_name="mobenga"
cur_dir=`dirname ${BASH_SOURCE[0]}`
dump_archive=$1 # dump.tgz
host_name=$(hostname)
dump_dir="${cur_dir}/dump"
dump_db_dir="${dump_dir}/${db_name}"
mongo_restore_cmd="mongorestore"

function rm_dump_dir () {
   if [[ -e "${dump_dir}" ]]; then
   	 echo "removing ${dump_dir}"
     rm -rf $dump_dir
   fi
}

case "$host_name" in 
  *mtasb-mbg-priva-redis*)
    mongo_restore_cmd="/opt/local/mobenga/bin/mongorestore"
    ;;
esac

if [ "$_dbg" = true ]; then
  echo "db_name=${db_name}"
  echo "cur_dir=${cur_dir}"
  echo "host_name=${host_name}"
  echo "dump_archive=${dump_archive}"
  echo "dump_dir=${dump_dir}"
  echo "dump_db_dir=${dump_db_dir}"
  echo "mongo_restore_cmd=${mongo_restore_cmd}"
fi

# remove dump directory if exists
rm_dump_dir

if [[ ! -e "${dump_archive}" ]]; then
    echo "file does not exist: ${dump_archive}"
    exit 0
else
    echo "unarchiving ${dump_archive}"
    tar -xzvf $dump_archive

    if [[ -e "${dump_db_dir}" ]]; then
    	echo "restoring mongo dump from $dump_db_dir"
    	$mongo_restore_cmd --db=$db_name --drop --gzip $dump_db_dir
    fi
fi

# remove dump directory if exists
rm_dump_dir

