drop table if exists scholen;
create table scholen (
	naam varchar,
	type varchar,
	denominatie varchar,
	internetadres varchar,
	straat varchar,
	huisnummer int,
	huisletter varchar(1),
	huisnummertoevoeging varchar(4),
	postcode varchar(6),
	plaats varchar,
	gemeente varchar,
	provincie varchar,
	brin_nummer varchar,
	vestigingsnummer varchar,
	onderwijsgebied varchar,
	locatie geometry(point,4326)
);

-- zonder huisnummer toevoegingen
insert into scholen
   select s.vestigingsnaam naam,
	'basisschool' type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from public."02_alle_schoolvestigingen_basisonderwijs_utf8" s join adres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and to_number(s.huisnummer_toevoeging,'99999')=a.huisnummer)
	     where s.huisnummer_toevoeging not like '%-%' and a.huisletter is null and a.huisnummertoevoeging is null;

-- met huisletter
insert into scholen
   select s.vestigingsnaam naam,
	'basisschool' type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from public."02_alle_schoolvestigingen_basisonderwijs_utf8" s join adres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and s.huisnummer_toevoeging ilike a.huisnummer::text || '-' || a.huisletter)
	     where s.huisnummer_toevoeging like '%-%' and a.huisletter is not null and a.huisnummertoevoeging is null;

-- met huisnummertoevoeging
insert into scholen
   select s.vestigingsnaam naam,
	'basisschool' type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from public."02_alle_schoolvestigingen_basisonderwijs_utf8" s join adres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and s.huisnummer_toevoeging ilike a.huisnummer::text || '-' || a.huisnummertoevoeging)
	     where s.huisnummer_toevoeging like '%-%' and a.huisletter is null and a.huisnummertoevoeging is not null;

-- solve where straat numbers and housenumbers got mixed up
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen
 select s.vestigingsnaam naam,
    'basisschool' type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and replace(s.straatnaam, ' ', '') || s.huisnummer_toevoeging ilike replace(a.openbareruimtenaam, ' ', '') || a.huisnummer::text || '-' || a.huisletter)
		      where s.huisnummer_toevoeging like '%-%' and a.huisletter is not null and a.geopunt is not null;


-- map house number ranges to first house number		     
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen
 select s.vestigingsnaam naam,
    'basisschool' type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and to_number(regexp_replace(s.huisnummer_toevoeging, '([0-9]*)-([0-9]*)', '\1'),'9999') = a.huisnummer)
		      where a.huisletter is null and a.huisnummertoevoeging is null and a.geopunt is not null;

-- map house number ranges to last house number		     
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen
 select s.vestigingsnaam naam,
    'basisschool' type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (
              replace(s.postcode, ' ', '')=a.postcode 
		      and to_number(regexp_replace(s.huisnummer_toevoeging, '([0-9]*)-([0-9]*)', '\2'),'9999') = a.huisnummer
		  )
		where (regexp_match(s.huisnummer_toevoeging,'([0-9]*)-([0-9]*)'))[2] !='' 
                 and a.huisletter is null 
                 and a.huisnummertoevoeging is null 
                 and a.geopunt is not null;



-- map housenumbers without extension to housennumbers with extension using onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen
 select s.vestigingsnaam naam,
    'basisschool' type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and a.gebruiksdoel = 'onderwijsfunctie') and to_number(s.huisnummer_toevoeging, '99999')=a.huisnummer
		      where s.huisnummer_toevoeging not like '%-%' and a.geopunt is not null;

-- map to onderwijsfunctie in same postcode		     
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen
 select s.vestigingsnaam naam,
    'basisschool' type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	--s.huisnummer_toevoeging,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	a.postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and a.gebruiksdoel like '%onderwijsfunctie%')
		      where a.geopunt is not null;

-- map housenumbers without extension to housennumbers with extension ignoring onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen 
 (huisnummer, naam, type, denominatie, internetadres, straat, huisletter, huisnummertoevoeging, postcode, plaats, gemeente, provincie,
 	brin_nummer , vestigingsnummer , onderwijsgebied, locatie) 
 select distinct on (a.huisnummer) huisnummer, 
 	s.vestigingsnaam naam,
 	'basisschool' type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
            ) and to_number(s.huisnummer_toevoeging, '99999')=a.huisnummer
		      where s.huisnummer_toevoeging not like '%-%' and a.geopunt is not null;

-- map on same street in same town using gebruiksdoel onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen 
 (huisnummer, naam, type, denominatie, internetadres, straat, huisletter, huisnummertoevoeging, postcode, plaats, gemeente, provincie,
 	brin_nummer , vestigingsnummer , onderwijsgebied, locatie) 
 select distinct on (a.huisnummer) huisnummer, 
 	s.vestigingsnaam naam,
 	'basisschool' type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (left(s.postcode,4)=left(a.postcode,4) 
             and s.straatnaam = a.openbareruimtenaam) 
				where a.gebruiksdoel like '%onderwijsfunctie%'
				and a.geopunt is not null;


--- VOORTGEZET ONDERWIJS
--- VOORTGEZET ONDERWIJS
--- VOORTGEZET ONDERWIJS
--- VOORTGEZET ONDERWIJS

-- zonder huisnummer toevoegingen
insert into scholen
   select s.vestigingsnaam naam,
	onderwijsstructuur type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from public."02_alle_vestigingen_vo_utf8" s join adres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and to_number(s.huisnummer_toevoeging,'99999')=a.huisnummer)
	     where s.huisnummer_toevoeging not like '%-%' and a.huisletter is null and a.huisnummertoevoeging is null;

-- met huisletter
insert into scholen
   select s.vestigingsnaam naam,
	onderwijsstructuur type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from public."02_alle_vestigingen_vo_utf8" s join adres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and s.huisnummer_toevoeging ilike a.huisnummer::text || '-' || a.huisletter)
	     where s.huisnummer_toevoeging like '%-%' and a.huisletter is not null and a.huisnummertoevoeging is null;

-- met huisnummertoevoeging
insert into scholen
   select s.vestigingsnaam naam,
	onderwijsstructuur type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from public."02_alle_vestigingen_vo_utf8" s join adres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and s.huisnummer_toevoeging ilike a.huisnummer::text || '-' || a.huisnummertoevoeging)
	     where s.huisnummer_toevoeging like '%-%' and a.huisletter is null and a.huisnummertoevoeging is not null;

-- solve where straat numbers and housenumbers got mixed up (Almere/Lelystraat 'straat 100', nr 10 => sometimes 'straat', nr 10010)
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen
 select s.vestigingsnaam naam,
    onderwijsstructuur type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and replace(s.straatnaam, ' ', '') || s.huisnummer_toevoeging ilike replace(a.openbareruimtenaam, ' ', '') || a.huisnummer::text || '-' || a.huisletter)
		      where s.huisnummer_toevoeging like '%-%' and a.huisletter is not null and a.geopunt is not null;


-- map house number ranges to first house number		     
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen
 select s.vestigingsnaam naam,
    onderwijsstructuur type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and to_number(regexp_replace(s.huisnummer_toevoeging, '([0-9]*)-([0-9]*)', '\1'),'9999') = a.huisnummer)
		      where a.huisletter is null and a.huisnummertoevoeging is null and a.geopunt is not null;

-- map house number ranges to last house number		     
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen
 select s.vestigingsnaam naam,
    onderwijsstructuur type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (
              replace(s.postcode, ' ', '')=a.postcode 
		      and to_number(regexp_replace(s.huisnummer_toevoeging, '([0-9]*)-([0-9]*)', '\2'),'9999') = a.huisnummer
		  )
		where (regexp_match(s.huisnummer_toevoeging,'([0-9]*)-([0-9]*)'))[2] !='' 
                 and a.huisletter is null 
                 and a.huisnummertoevoeging is null 
                 and a.geopunt is not null;



-- map housenumbers without extension to housennumbers with extension using onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen
 select s.vestigingsnaam naam,
    onderwijsstructuur type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and a.gebruiksdoel = 'onderwijsfunctie') and to_number(s.huisnummer_toevoeging, '99999')=a.huisnummer
		      where s.huisnummer_toevoeging not like '%-%' and a.geopunt is not null;

-- map to onderwijsfunctie in same postcode		     
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen
 select s.vestigingsnaam naam,
    onderwijsstructuur type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	--s.huisnummer_toevoeging,
	a.huisnummer,
	a.huisletter,
	a.huisnummertoevoeging,
	a.postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and a.gebruiksdoel like '%onderwijsfunctie%')
		      where a.geopunt is not null;


-- map housenumbers without extension to housennumbers with extension ignoring onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen 
 (huisnummer, naam, type, denominatie, internetadres, straat, huisletter, huisnummertoevoeging, postcode, plaats, gemeente, provincie,
 	brin_nummer , vestigingsnummer , onderwijsgebied, locatie) 
 select distinct on (a.huisnummer) huisnummer, 
 	s.vestigingsnaam naam,
 	s.onderwijsstructuur type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
            ) and to_number(s.huisnummer_toevoeging, '99999')=a.huisnummer
		      where s.huisnummer_toevoeging not like '%-%' and a.geopunt is not null;

-- map on same street in same town using gebruiksdoel onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from public."02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null)
 insert into scholen 
 (huisnummer, naam, type, denominatie, internetadres, straat, huisletter, huisnummertoevoeging, postcode, plaats, gemeente, provincie,
 	brin_nummer , vestigingsnummer , onderwijsgebied, locatie) 
 select distinct on (a.huisnummer) huisnummer, 
 	s.vestigingsnaam naam,
 	s.onderwijsstructuur type,
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."brin nummer" brin_nummer,
	s.vestigingsnummer,
	s."onderwijsgebied naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join adres a
		  on (left(s.postcode,4)=left(a.postcode,4) 
             and s.straatnaam = a.openbareruimtenaam) 
				where a.gebruiksdoel like '%onderwijsfunctie%'
				and a.geopunt is not null;
