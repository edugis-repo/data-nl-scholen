# data-nl-scholen
Conversion and geocoding of dutch school locations (elementary and secondary education)

## Prerequisites
* postgresql
* postgis
* ogr2ogr
* iconv
* (Recent) BAG data

## Steps
1. download address data (CSV)
2. convert ANSI to UTF8 (CSV-ANSI => CSV-UTF8)
3. import into Postgres database (ogr2ogr)
4. use sql queries to create geocoded table (using BAG data)
5. export to geojson


## Download
Download adresses via:
https://www.rijksoverheid.nl/contact/contactgids/scholen-in-nederland

URLS (as per 2022-05-01):   
[02-alle-schoolvestigingen-basisonderwijs.csv](https://www.duo.nl/open_onderwijsdata/primair-onderwijs/scholen-en-adressen/schoolvestigingen-basisonderwijs.jsp) (basisscholen)   
[02-alle-vestigingen-vo.csv](https://www.duo.nl/open_onderwijsdata/images/02-alle-vestigingen-vo.csv) (voortgezet onderwijs)   
[01-adressen-instellingen.csv](https://duo.nl/open_onderwijsdata/images/01-adressen-instellingen.csv) (mbo)   
[01-instellingen-hbo-en-wo.csv](https://duo.nl/open_onderwijsdata/images/01-instellingen-hbo-en-wo.csv)  (hogescholen en universiteiten)   
[02-instellingen-pabo.csv](https://duo.nl/open_onderwijsdata/images/02-instellingen-pabo.csv) (pabo)   

The above csv files are ANSI-encoded (alias windows-1252).

## Convert to UTF8
```bash
iconv -f "windows-1252" -t "UTF-8" 02-alle-schoolvestigingen-basisonderwijs.csv -o 02-alle-schoolvestigingen-basisonderwijs-utf8.csv
iconv -f "windows-1252" -t "UTF-8" 02-alle-vestigingen-vo.csv -o 02-alle-vestigingen-vo-utf8.csv
iconv -f "windows-1252" -t "UTF-8" 01-adressen-instellingen.csv -o 01-adressen-instellingen-utf8.csv
iconv -f "windows-1252" -t "UTF-8" 01-instellingen-hbo-en-wo.csv -o 01-instellingen-hbo-en-wo-utf8.csv
iconv -f "windows-1252" -t "UTF-8" 02-instellingen-pabo.csv -o 02-instellingen-pabo-utf8.csv
```

## import into Postgresql
```bash
export PGPASSWORD=mydbpassword
ogr2ogr -f PostgreSQL PG:"host=localhost user=postgres dbname=mydbname" 02-alle-schoolvestigingen-basisonderwijs-utf8.csv -oo AUTODETECT_TYPE=YES
ogr2ogr -f PostgreSQL PG:"host=localhost user=postgres dbname=mydbname" 02-alle-vestigingen-vo-utf8.csv -oo AUTODETECT_TYPE=YES
ogr2ogr -f PostgreSQL PG:"host=localhost user=postgres dbname=mydbname" 01-adressen-instellingen-utf8.csv -oo AUTODETECT_TYPE=YES
ogr2ogr -f PostgreSQL PG:"host=localhost user=postgres dbname=mydbname" 01-instellingen-hbo-en-wo-utf8.csv -oo AUTODETECT_TYPE=YES
ogr2ogr -f PostgreSQL PG:"host=localhost user=postgres dbname=mydbname" 02-instellingen-pabo-utf8.csv -oo AUTODETECT_TYPE=YES
```

## create table 'scholen'
```bash
export PGPASSWORD=mydbpassword
psql -h localhost -U postgres mydbname < geocode.sql
```

