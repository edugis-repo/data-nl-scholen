#!/bin/bash

# check if environment variables are set or output error message
if [ -z "$PGDATABASE" ]; then
    echo "Please set the environment variable PGDATABASE"
    exit 1
fi
if [ -z "$PGUSER" ]; then
    echo "Please set the environment variable PGUSER"
    exit 1
fi
if [ -z "$PGPASSWORD" ]; then
    echo "Please set the environment variable PGPASSWORD"
    exit 1
fi
if [ -z "$PGHOST" ]; then
    echo "Please set the environment variable PGHOST"
    exit 1
fi

psql -c "DROP TABLE IF EXISTS \"02_alle_schoolvestigingen_basisonderwijs_utf8\";"
psql -c "CREATE TABLE \"02_alle_schoolvestigingen_basisonderwijs_utf8\" (
    provincie TEXT,
    bevoegd_gezag_nummer INTEGER,
    instellingencode TEXT,
    vestigingscode TEXT,
    vestigingsnaam TEXT,
    straatnaam TEXT,
    huisnummer_toevoeging TEXT,
    postcode TEXT,
    plaatsnaam TEXT,
    gemeentecode INTEGER,
    gemeentenaam TEXT,
    denominatie TEXT,
    telefoonnummer TEXT,
    internetadres TEXT,
    straatnaam_correspondentieadres TEXT,
    huisnummer_toevoeging_correspondentieadres TEXT,
    postcode_correspondentieadres TEXT,
    plaatsnaam_correspondentieadres TEXT,
    nodaal_gebied_code INTEGER,
    nodaal_gebied_naam TEXT,
    rpa_gebied_code INTEGER,
    rpa_gebied_naam TEXT,
    wgr_gebied_code INTEGER,
    wgr_gebied_naam TEXT,
    coropgebied_code INTEGER,
    coropgebied_naam TEXT,
    onderwijsgebied_code INTEGER,
    onderwijsgebied_naam TEXT,
    rmc_regio_code INTEGER,
    rmc_regio_naam TEXT,
    vakantieregio TEXT
);"
psql -c "\copy \"02_alle_schoolvestigingen_basisonderwijs_utf8\" FROM 'data/02-alle-schoolvestigingen-basisonderwijs-utf8.csv' DELIMITER ';' CSV HEADER;"

psql -c "DROP TABLE IF EXISTS \"02_alle_vestigingen_vo_utf8\";"
psql -c "CREATE TABLE \"02_alle_vestigingen_vo_utf8\" (
    provincie TEXT,
    bevoegd_gezag_nummer TEXT,
    instellingencode TEXT,
    vestigingscode TEXT,
    vestigingsnaam TEXT,
    straatnaam TEXT,
    huisnummer_toevoeging TEXT,
    postcode TEXT,
    plaatsnaam TEXT,
    gemeentecode INTEGER,
    gemeentenaam TEXT,
    denominatie TEXT,
    telefoonnummer TEXT,
    internetadres TEXT,
    onderwijsstructuur TEXT,
    straatnaam_correspondentieadres TEXT,
    huisnummer_toevoeging_correspondentieadres TEXT,
    postcode_correspondentieadres TEXT,
    plaatsnaam_correspondentieadres TEXT,
    nodaal_gebied_code INTEGER,
    nodaal_gebied_naam TEXT,
    rpa_gebied_code INTEGER,
    rpa_gebied_naam TEXT,
    wgr_gebied_code INTEGER,
    wgr_gebied_naam TEXT,
    coropgebied_code INTEGER,
    coropgebied_naam TEXT,
    onderwijsgebied_code INTEGER,
    onderwijsgebied_naam TEXT,
    rmc_regio_code INTEGER,
    rmc_regio_naam TEXT,
    vakantieregio TEXT
);"
psql -c "\copy \"02_alle_vestigingen_vo_utf8\" FROM 'data/02-alle-vestigingen-vo-utf8.csv' DELIMITER ';' CSV HEADER;"

psql -c "DROP TABLE IF EXISTS \"01_adressen_instellingen_utf8\";"
psql -c "CREATE TABLE \"01_adressen_instellingen_utf8\" (
    mbo_instellingssoort_code TEXT,
    mbo_instellingssoort_naam TEXT,
    provincie TEXT,
    bevoegd_gezag_nummer INTEGER,
    instellingencode TEXT,
    instellingsnaam TEXT,
    straatnaam TEXT,
    huisnummer_toevoeging TEXT,
    postcode TEXT,
    plaatsnaam TEXT,
    gemeentecode INTEGER,
    gemeentenaam TEXT,
    denominatie TEXT,
    telefoonnummer TEXT,
    internetadres TEXT,
    straatnaam_correspondentieadres TEXT,
    huisnummer_toevoeging_correspondentieadres TEXT,
    postcode_correspondentieadres TEXT,
    plaatsnaam_correspondentieadres TEXT,
    nodaal_gebied_code INTEGER,
    nodaal_gebied_naam TEXT,
    rpa_gebied_code INTEGER,
    rpa_gebied_naam TEXT,
    wgr_gebied_code INTEGER,
    wgr_gebied_naam TEXT,
    coropgebied_code INTEGER,
    coropgebied_naam TEXT,
    onderwijsgebied_code INTEGER,
    onderwijsgebied_naam TEXT,
    rmc_regio_code INTEGER,
    rmc_regio_naam TEXT
);"
psql -c "\copy \"01_adressen_instellingen_utf8\" FROM 'data/01-adressen-instellingen-utf8.csv' DELIMITER ';' CSV HEADER;"

psql -c "DROP TABLE IF EXISTS \"01_instellingen_hbo_en_wo_utf8\";"
psql -c "CREATE TABLE \"01_instellingen_hbo_en_wo_utf8\" (
    soort_ho TEXT,
    provincie TEXT,
    bevoegd_gezag_nummer TEXT,
    instellingencode TEXT,
    instellingsnaam TEXT,
    straatnaam TEXT,
    huisnummer_toevoeging TEXT,
    postcode TEXT,
    plaatsnaam TEXT,
    gemeentecode INTEGER,
    gemeentenaam TEXT,
    denominatie TEXT,
    telefoonnummer TEXT,
    internetadres TEXT,
    straatnaam_correspondentieadres TEXT,
    huisnummer_toevoeging_correspondentieadres TEXT,
    postcode_correspondentieadres TEXT,
    plaatsnaam_correspondentieadres TEXT,
    nodaal_gebied_code INTEGER,
    nodaal_gebied_naam TEXT,
    rpa_gebied_code INTEGER,
    rpa_gebied_naam TEXT,
    wgr_gebied_code INTEGER,
    wgr_gebied_naam TEXT,
    coropgebied_code INTEGER,
    coropgebied_naam TEXT,
    onderwijsgebied_code INTEGER,
    onderwijsgebied_naam TEXT,
    rmc_regio_code INTEGER,
    rmc_regio_naam TEXT
);"
psql -c "\copy \"01_instellingen_hbo_en_wo_utf8\" FROM 'data/01-instellingen-hbo-en-wo-utf8.csv' DELIMITER ';' CSV HEADER;"

psql -c "DROP TABLE IF EXISTS \"02_instellingen_pabo_utf8\";"
psql -c "CREATE TABLE \"02_instellingen_pabo_utf8\" (
    soort_ho TEXT,
    provincie TEXT,
    bevoegd_gezag_nummer TEXT,
    instellingencode TEXT,
    instellingsnaam TEXT,
    straatnaam TEXT,
    huisnummer_toevoeging TEXT,
    postcode TEXT,
    plaatsnaam TEXT,
    gemeentecode TEXT,
    gemeentenaam TEXT,
    denominatie TEXT,
    telefoonnummer TEXT,
    internetadres TEXT,
    straatnaam_correspondentieadres TEXT,
    huisnummer_toevoeging_correspondentieadres TEXT,
    postcode_correspondentieadres TEXT,
    plaatsnaam_correspondentieadres TEXT,
    nodaal_gebied_code TEXT,
    nodaal_gebied_naam TEXT,
    rpa_gebied_code TEXT,
    rpa_gebied_naam TEXT,
    wgr_gebied_code TEXT,
    wgr_gebied_naam TEXT,
    coropgebied_code TEXT,
    coropgebied_naam TEXT,
    onderwijsgebied_code TEXT,
    onderwijsgebied_naam TEXT,
    rmc_regio_naam TEXT
);"
psql -c "\copy \"02_instellingen_pabo_utf8\" FROM 'data/02-instellingen-pabo-utf8.csv' DELIMITER ';' CSV HEADER;"