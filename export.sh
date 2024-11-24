ogr2ogr -f "GeoJSON" scholen.geo.json PG:"host=${PGHOST} dbname=${PGDATABASE} user=${PGUSER} password=${PGPASSWORD} port=5432" "scholen"

