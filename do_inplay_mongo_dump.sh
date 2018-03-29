#!/usr/bin/env bash

#colls=( eventGroups_en event_en viewSports sportList_en sport_en viewTypes )
#colls=( eventGroups_en eventView eventVisualisation event_en inplayDetails_en job marketGroups_en marketView market_en queueInfo selectionView sportClassView sportClass_en sportList_en sportView sport_en type_en viewSports viewTypes views )

colls=( eventGroups_en eventVisualisation event_en inplayDetails_en job marketGroups_en marketView queueInfo sportClassView sportClass_en sportList_en sportView sport_en type_en viewSports viewTypes views )

#
# vars
#
_dbg=true
db_name="mobenga"
cur_dir=`dirname ${BASH_SOURCE[0]}`
date_time=$(date '+%Y-%m-%d_%H-%M-%S')
host_name=$(hostname)
dump_archive="${cur_dir}/${host_name}_${date_time}.tgz"
dump_dir="${cur_dir}/dump"
dump_db_dir="${dump_dir}/${db_name}"
mongo_dump_cmd="mongodump"

case "$host_name" in 
  *mtasb-mbg-priva-redis*)
    mongo_dump_cmd="/opt/local/mobenga/bin/mongodump"
    ;;
esac

if [ "$_dbg" = true ]; then
  echo "db_name=${db_name}"
  echo "cur_dir=${cur_dir}"
  echo "date_time=${date_time}"
  echo "host_name=${host_name}"
  echo "dump_archive=${dump_archive}"
  echo "dump_dir=${dump_dir}"
  echo "dump_db_dir=${dump_db_dir}"
  echo "mongo_dump_cmd=${mongo_dump_cmd}"
fi

function rm_dump_dir () {
   if [[ -e "${dump_dir}" ]]; then
   	 echo "removing ${dump_dir}"
     rm -rf $dump_dir
   fi
}

# remove dump directory if exists
rm_dump_dir

# exclude big collections: eventView, market_en, selectionView
colls=( eventGroups_en eventVisualisation event_en inplayDetails_en job marketGroups_en marketView queueInfo sportClassView sportClass_en sportList_en sportView sport_en type_en viewSports viewTypes views )

# make collection dump
for c in ${colls[@]}
do
  $mongo_dump_cmd --db=$db_name --collection=$c --gzip --verbose
done

# Archive mongo dump
if [[ -e "${dump_db_dir}" ]]; then
  echo "archiving ${dump_db_dir}/* -> ${dump_archive}"
  tar -czvf $dump_archive $dump_db_dir/*
fi

# remove dump directory if exists
rm_dump_dir