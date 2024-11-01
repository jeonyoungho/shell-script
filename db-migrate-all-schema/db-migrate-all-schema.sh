#!/usr/bin/bash

SQL_FILE=$1

DB_HOST= # DB 호스트 상수 정의
DB_PORT= # DB 포트 상수 정의
DB_ACCOUNT_ID= # DB 계정 ID 상수 정의
DB_ACCOUNT_PW= # DB 계정 PW 상수 정의

echo "##################################################################################";
echo "SQL_FILE: ${SQL_FILE}";
echo "DB_HOST: ${DB_HOST}";
echo "DB_PORT: ${DB_PORT}";
echo -e "##################################################################################\n";

# validate argument size
if [ $# -ne 1 ]
then
  echo "Could not execute migrate query. Because argument size is invalid. Please enter the correct arguments according to the readme file"
  exit 22
fi

# validate sql_file
if [ ${SQL_FILE:(-4)} != ".sql" ]; then
	echo "Could not execute migrate query. Because '$SQL_FILE' is not sql file extension!!!"
	exit 22
fi

if [ ! -f "$SQL_FILE" ]; then
	echo "Could not execute migrate query. Because '$SQL_FILE' is not exists!!!"
	exit 22
fi

SCHEMA_SELECT_QUERY="show databases where 'database' not in ('innodb', 'sys', 'tmp');"
mysql --user=${DB_ACCOUNT_ID} --password=${DB_ACCOUNT_PW} --host=${DB_HOST} --port=${DB_PORT} --skip-column-names --execute="${SCHEMA_SELECT_QUERY}" --batch --skip-column-names > schemas.txt
sed -i 's/\r$//' schemas.txt

##  조회
# SELECT_RESULT_FILE_PATH=select_result.txt
# if [ -e ${SELECT_RESULT_FILE_PATH} ]; then
#     # Delete the file
#     rm ${SELECT_RESULT_FILE_PATH}
#     echo "File '${SELECT_RESULT_FILE_PATH}' deleted."
# else
#     echo "File '${SELECT_RESULT_FILE_PATH}' does not exist."
# fi

COUNT=0
while read SCHEMA; do
	if [ -z "$SCHEMA" ]; then continue; fi
		
	echo "== start -> SCHEMA: ${SCHEMA} =="
	# 실행
	mysql "--host=${DB_HOST} --port=${DB_PORT} --user=${DB_ACCOUNT_ID} --password=${DB_ACCOUNT_PW}" $SCHEMA < $SQL_FILE
	
	# 조회
	# echo "[${SCHEMA}] => $(mysql --host=${DB_HOST} --port=${DB_PORT} --user=${DB_ACCOUNT_ID} --password=${DB_ACCOUNT_PW} ${SCHEMA} --skip-column-names --execute="source ${SQL_FILE}")" >> ${SELECT_RESULT_FILE_PATH}
	
	((COUNT+=1))
	
	echo -e "== end -> schema: ${SCHEMA} ==\n"
done < schemas.txt

echo "Execution was completed for a total of $COUNT schemas."


