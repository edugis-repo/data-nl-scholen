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

# create index on table scholen
psql -c "create index if not exists scholen_vestigingscode_idx on scholen (vestigingscode);"
# add leerlingen to scholen table
psql -c "ALTER TABLE scholen ADD COLUMN leerlingen INT;"

# import leerling aantallen voortgezet onderwijs
psql -c "DROP TABLE IF EXISTS \"09_leerlingen_vo_per_vestiging_naar_onderwijstype\";"
psql -c "CREATE TABLE \"09_leerlingen_vo_per_vestiging_naar_onderwijstype\" (
    instelling TEXT,
    vestigingsnummer INTEGER,
    instellingsnaam_vestiging TEXT,
    plaatsnaam_vestiging TEXT,
    provincie_vestiging TEXT,
    samenwerkingsverband_passend_onderwijs_vo TEXT,
    onderwijstype_vo_en_leer_of_verblijfsjaar TEXT,
    vmbo_sector TEXT,
    afdeling TEXT,
    erkende_opleidingscode INTEGER,
    opleidingsnaam TEXT,
    leerjaar1_man TEXT,
    leerjaar1_vrouw TEXT,
    leerjaar2_man TEXT,
    leerjaar2_vrouw TEXT,
    leerjaar3_man TEXT,
    leerjaar3_vrouw TEXT,
    leerjaar4_man TEXT,
    leerjaar4_vrouw TEXT,
    leerjaar5_man TEXT,
    leerjaar5_vrouw TEXT,
    leerjaar6_man TEXT,
    leerjaar6_vrouw TEXT
);"
psql -c "\copy \"09_leerlingen_vo_per_vestiging_naar_onderwijstype\" FROM 'data/01.-leerlingen-vo-per-vestiging-naar-onderwijstype-2023.csv' DELIMITER ';' CSV HEADER;"


# update leerlingen voortgezet onderwijs into scholen table
psql -c "with leerlingen_per_vestiging as (SELECT 
    instelling || to_char(vestigingsnummer, 'FM00') vestigingscode,
    sum (
    COALESCE(
        CASE WHEN leerjaar1_man = '<5' THEN 2 ELSE NULLIF(leerjaar1_man, '<5')::INTEGER END, 0
    ) +
    COALESCE(
        CASE WHEN leerjaar1_vrouw = '<5' THEN 2 ELSE NULLIF(leerjaar1_vrouw, '<5')::INTEGER END, 0
    ) +
    COALESCE(
        CASE WHEN leerjaar2_man = '<5' THEN 2 ELSE NULLIF(leerjaar2_man, '<5')::INTEGER END, 0
    ) +
    COALESCE(
        CASE WHEN leerjaar2_vrouw = '<5' THEN 2 ELSE NULLIF(leerjaar2_vrouw, '<5')::INTEGER END, 0
    ) +
    COALESCE(
        CASE WHEN leerjaar3_man = '<5' THEN 2 ELSE NULLIF(leerjaar3_man, '<5')::INTEGER END, 0
    ) +
    COALESCE(
        CASE WHEN leerjaar3_vrouw = '<5' THEN 2 ELSE NULLIF(leerjaar3_vrouw, '<5')::INTEGER END, 0
    ) +
    COALESCE(
        CASE WHEN leerjaar4_man = '<5' THEN 2 ELSE NULLIF(leerjaar4_man, '<5')::INTEGER END, 0
    ) +
    COALESCE(
        CASE WHEN leerjaar4_vrouw = '<5' THEN 2 ELSE NULLIF(leerjaar4_vrouw, '<5')::INTEGER END, 0
    ) +
    COALESCE(
        CASE WHEN leerjaar5_man = '<5' THEN 2 ELSE NULLIF(leerjaar5_man, '<5')::INTEGER END, 0
    ) +
    COALESCE(
        CASE WHEN leerjaar5_vrouw = '<5' THEN 2 ELSE NULLIF(leerjaar5_vrouw, '<5')::INTEGER END, 0
    ) +
    COALESCE(
        CASE WHEN leerjaar6_man = '<5' THEN 2 ELSE NULLIF(leerjaar6_man, '<5')::INTEGER END, 0
    ) +
    COALESCE(
        CASE WHEN leerjaar6_vrouw = '<5' THEN 2 ELSE NULLIF(leerjaar6_vrouw, '<5')::INTEGER END, 0
    ) ) as leerlingen
FROM \"09_leerlingen_vo_per_vestiging_naar_onderwijstype\" group by instelling,vestigingsnummer)
 update scholen s set leerlingen=lpv.leerlingen
  from leerlingen_per_vestiging lpv 
    where lpv.vestigingscode = s.vestigingscode;"


psql -c "DROP TABLE IF EXISTS \"01_leerlingen_po_soort_po_cluster_leeftijd\";"
psql -c "CREATE TABLE \"01_leerlingen_po_soort_po_cluster_leeftijd\" (
    peildatum DATE,
    instellingencode TEXT,
    vestigingscode TEXT,
    instellingsnaam_vestiging TEXT,
    postcode_vestiging TEXT,
    plaatsnaam TEXT,
    gemeentennummer INTEGER,
    gemeentenaam TEXT,
    provincie TEXT,
    soort_po TEXT,
    cluster TEXT,
    denominatie_vestiging TEXT,
    bevoegd_gezag_nummer INTEGER,
    leeftijd_jonger TEXT,
    leeftijd_4 TEXT,
    leeftijd_5 TEXT,
    leeftijd_6 TEXT,
    leeftijd_7 TEXT,
    leeftijd_8 TEXT,
    leeftijd_9 TEXT,
    leeftijd_10 TEXT,
    leeftijd_11 TEXT,
    leeftijd_12 TEXT,
    leeftijd_13 TEXT,
    leeftijd_14 TEXT,
    leeftijd_15 TEXT,
    leeftijd_16 TEXT,
    leeftijd_17 TEXT,
    leeftijd_18 TEXT,
    leeftijd_19 TEXT,
    leeftijd_20 TEXT,
    leeftijd_21 TEXT,
    leeftijd_22 TEXT,
    leeftijd_23 TEXT,
    leeftijd_24 TEXT,
    leeftijd_ouder TEXT
);"
psql -c "\copy \"01_leerlingen_po_soort_po_cluster_leeftijd\" FROM 'data/01.-leerlingen-po-soort-po-cluster-leeftijd.csv' DELIMITER ';' CSV HEADER;"

# update leerlingen primair onderwijs into scholen table
psql -c "
with leerlingen_per_vestiging as (SELECT 
    instellingencode || vestigingscode vestigingscode,
    sum(
    COALESCE(CASE WHEN leeftijd_jonger = '<5' THEN 2 ELSE NULLIF(leeftijd_jonger, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_4 = '<5' THEN 2 ELSE NULLIF(leeftijd_4, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_5 = '<5' THEN 2 ELSE NULLIF(leeftijd_5, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_6 = '<5' THEN 2 ELSE NULLIF(leeftijd_6, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_7 = '<5' THEN 2 ELSE NULLIF(leeftijd_7, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_8 = '<5' THEN 2 ELSE NULLIF(leeftijd_8, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_9 = '<5' THEN 2 ELSE NULLIF(leeftijd_9, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_10 = '<5' THEN 2 ELSE NULLIF(leeftijd_10, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_11 = '<5' THEN 2 ELSE NULLIF(leeftijd_11, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_12 = '<5' THEN 2 ELSE NULLIF(leeftijd_12, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_13 = '<5' THEN 2 ELSE NULLIF(leeftijd_13, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_14 = '<5' THEN 2 ELSE NULLIF(leeftijd_14, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_15 = '<5' THEN 2 ELSE NULLIF(leeftijd_15, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_16 = '<5' THEN 2 ELSE NULLIF(leeftijd_16, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_17 = '<5' THEN 2 ELSE NULLIF(leeftijd_17, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_18 = '<5' THEN 2 ELSE NULLIF(leeftijd_18, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_19 = '<5' THEN 2 ELSE NULLIF(leeftijd_19, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_20 = '<5' THEN 2 ELSE NULLIF(leeftijd_20, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_21 = '<5' THEN 2 ELSE NULLIF(leeftijd_21, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_22 = '<5' THEN 2 ELSE NULLIF(leeftijd_22, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_23 = '<5' THEN 2 ELSE NULLIF(leeftijd_23, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_24 = '<5' THEN 2 ELSE NULLIF(leeftijd_24, '<5')::INTEGER END, 0) +
    COALESCE(CASE WHEN leeftijd_ouder = '<5' THEN 2 ELSE NULLIF(leeftijd_ouder, '<5')::INTEGER END, 0)
    ) leerlingen
FROM \"01_leerlingen_po_soort_po_cluster_leeftijd\" 
  group by 1
)
update scholen s set leerlingen=lpv.leerlingen
  from leerlingen_per_vestiging lpv 
    where lpv.vestigingscode = s.vestigingscode;"