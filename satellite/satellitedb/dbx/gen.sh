#!/bin/sh

dbx schema -d postgres -d cockroach satellitedb.dbx .
dbx golang -d postgres -d cockroach -p dbx -t templates satellitedb.dbx .
( echo '//lint:file-ignore * generated file'; cat satellitedb.dbx.go ) > satellitedb.dbx.go.tmp && mv satellitedb.dbx.go.tmp satellitedb.dbx.go
gofmt -r "*sql.Tx -> tagsql.Tx" -w satellitedb.dbx.go
gofmt -r "*sql.Rows -> tagsql.Rows" -w satellitedb.dbx.go
perl -0777 -pi \
  -e 's,\t"github.com/lib/pq"\n\),\t"github.com/lib/pq"\n\n\t"storj.io/storj/private/tagsql"\n\),' \
  satellitedb.dbx.go
perl -0777 -pi \
  -e 's/type DB struct \{\n\t\*sql\.DB/type DB struct \{\n\ttagsql.DB/' \
  satellitedb.dbx.go
perl -0777 -pi \
  -e 's/\tdb = &DB\{\n\t\tDB: sql_db,/\tdb = &DB\{\n\t\tDB: tagsql.Wrap\(sql_db\),/' \
  satellitedb.dbx.go
