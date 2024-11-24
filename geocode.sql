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
	vestigingscode varchar,
	onderwijsgebied varchar,
	locatie geometry(point,4326)
);

--- BASISONDERWIJS

-- basisonderwijs zonder huisnummer toevoegingen
insert into scholen
   select s.vestigingsnaam naam,
	'basisschool' "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from "02_alle_schoolvestigingen_basisonderwijs_utf8" s join bag20241122.bagadres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and to_number(s.huisnummer_toevoeging,'99999')=a.huisnummer)
	     where s.huisnummer_toevoeging not like '%-%' and a.huisletter is null and a.huisnummertoevoeging is null;

-- basisonderwijs met huisletter
insert into scholen
   select s.vestigingsnaam naam,
	'basisschool' "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from "02_alle_schoolvestigingen_basisonderwijs_utf8" s join bag20241122.bagadres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and s.huisnummer_toevoeging ilike a.huisnummer::text || '-' || a.huisletter)
	     where s.huisnummer_toevoeging like '%-%' and a.huisletter is not null and a.huisnummertoevoeging is null;

-- basisonderwijs met huisnummertoevoeging
insert into scholen
   select s.vestigingsnaam naam,
	'basisschool' "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from "02_alle_schoolvestigingen_basisonderwijs_utf8" s join bag20241122.bagadres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and s.huisnummer_toevoeging ilike a.huisnummer::text || '-' || a.huisnummertoevoeging)
	     where s.huisnummer_toevoeging like '%-%' and a.huisletter is null and a.huisnummertoevoeging is not null;

-- basisonderwijs: solve where straat numbers and housenumbers got mixed up
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
    'basisschool' "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and replace(s.straatnaam, ' ', '') || s.huisnummer_toevoeging ilike replace(a.openbareruimtenaam, ' ', '') || a.huisnummer::text || '-' || a.huisletter)
		      where s.huisnummer_toevoeging like '%-%' and a.huisletter is not null and a.geopunt is not null;


-- basisonderwijs: map house number ranges to first house number	     
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
    'basisschool' "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and to_number(regexp_replace(s.huisnummer_toevoeging, '([0-9]*)-([0-9]*)', '\1'),'9999') = a.huisnummer)
		      where a.huisletter is null and a.huisnummertoevoeging is null and a.geopunt is not null;

-- basisonderwijs: map house number ranges to last house number		     
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
    'basisschool' "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (
              replace(s.postcode, ' ', '')=a.postcode 
		      and to_number(regexp_replace(s.huisnummer_toevoeging, '([0-9]*)-([0-9]*)', '\2'),'9999') = a.huisnummer
		  )
		where (regexp_match(s.huisnummer_toevoeging,'([0-9]*)-([0-9]*)'))[2] !='' 
                 and a.huisletter is null 
                 and a.huisnummertoevoeging is null 
                 and a.geopunt is not null;



-- basisonderwijs: map housenumbers without extension to housennumbers with extension using onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
    'basisschool' "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and a.gebruiksdoel = 'onderwijsfunctie') and to_number(s.huisnummer_toevoeging, '99999')=a.huisnummer
		      where s.huisnummer_toevoeging not like '%-%' and a.geopunt is not null;

-- basisonderwijs: map to onderwijsfunctie in same postcode		     
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
    'basisschool' "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and a.gebruiksdoel like '%onderwijsfunctie%')
		      where a.geopunt is not null;

-- basisonderwijs: map housenumbers without extension to house numbers with extension ignoring onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen 
 (huisnummer, naam, type, denominatie, internetadres, straat, huisletter, huisnummertoevoeging, postcode, plaats, gemeente, provincie,
 	brin_nummer , vestigingscode , onderwijsgebied, locatie) 
 select distinct on (a.huisnummer) huisnummer, 
 	s.vestigingsnaam naam,
 	'basisschool' "type",
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
            ) and to_number(s.huisnummer_toevoeging, '99999')=a.huisnummer
		      where s.huisnummer_toevoeging not like '%-%' and a.geopunt is not null;

-- map on same street in same town using gebruiksdoel onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_schoolvestigingen_basisonderwijs_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen 
 (huisnummer, naam, type, denominatie, internetadres, straat, huisletter, huisnummertoevoeging, postcode, plaats, gemeente, provincie,
 	brin_nummer , vestigingscode , onderwijsgebied, locatie) 
 select distinct on (a.huisnummer) huisnummer, 
 	s.vestigingsnaam naam,
 	'basisschool' "type",
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
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
	onderwijsstructuur "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from "02_alle_vestigingen_vo_utf8" s join bag20241122.bagadres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and to_number(s.huisnummer_toevoeging,'99999')=a.huisnummer)
	     where s.huisnummer_toevoeging not like '%-%' and a.huisletter is null and a.huisnummertoevoeging is null;

-- met huisletter
insert into scholen
   select s.vestigingsnaam naam,
	onderwijsstructuur "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from "02_alle_vestigingen_vo_utf8" s join bag20241122.bagadres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and s.huisnummer_toevoeging ilike a.huisnummer::text || '-' || a.huisletter)
	     where s.huisnummer_toevoeging like '%-%' and a.huisletter is not null and a.huisnummertoevoeging is null;

-- met huisnummertoevoeging
insert into scholen
   select s.vestigingsnaam naam,
	onderwijsstructuur "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from "02_alle_vestigingen_vo_utf8" s join bag20241122.bagadres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and s.huisnummer_toevoeging ilike a.huisnummer::text || '-' || a.huisnummertoevoeging)
	     where s.huisnummer_toevoeging like '%-%' and a.huisletter is null and a.huisnummertoevoeging is not null;

-- solve where straat numbers and housenumbers got mixed up (Almere/Lelystraat 'straat 100', nr 10 => sometimes 'straat', nr 10010)
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
    onderwijsstructuur "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and replace(s.straatnaam, ' ', '') || s.huisnummer_toevoeging ilike replace(a.openbareruimtenaam, ' ', '') || a.huisnummer::text || '-' || a.huisletter)
		      where s.huisnummer_toevoeging like '%-%' and a.huisletter is not null and a.geopunt is not null;


-- map house number ranges to first house number		     
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
    onderwijsstructuur "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and to_number(regexp_replace(s.huisnummer_toevoeging, '([0-9]*)-([0-9]*)', '\1'),'9999') = a.huisnummer)
		      where a.huisletter is null and a.huisnummertoevoeging is null and a.geopunt is not null;

-- map house number ranges to last house number		     
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
    onderwijsstructuur "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
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
  from "02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
    onderwijsstructuur "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and a.gebruiksdoel = 'onderwijsfunctie') and to_number(s.huisnummer_toevoeging, '99999')=a.huisnummer
		      where s.huisnummer_toevoeging not like '%-%' and a.geopunt is not null;

-- map to onderwijsfunctie in same postcode		     
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
    onderwijsstructuur "type",
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
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and a.gebruiksdoel like '%onderwijsfunctie%')
		      where a.geopunt is not null;


-- map housenumbers without extension to housennumbers with extension ignoring onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen 
 (huisnummer, naam, type, denominatie, internetadres, straat, huisletter, huisnummertoevoeging, postcode, plaats, gemeente, provincie,
 	brin_nummer , vestigingscode , onderwijsgebied, locatie) 
 select distinct on (a.huisnummer) huisnummer, 
 	s.vestigingsnaam naam,
 	s.onderwijsstructuur "type",
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
            ) and to_number(s.huisnummer_toevoeging, '99999')=a.huisnummer
		      where s.huisnummer_toevoeging not like '%-%' and a.geopunt is not null;

-- map on same street in same town using gebruiksdoel onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from "02_alle_vestigingen_vo_utf8" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen 
 (huisnummer, naam, type, denominatie, internetadres, straat, huisletter, huisnummertoevoeging, postcode, plaats, gemeente, provincie,
 	brin_nummer , vestigingscode , onderwijsgebied, locatie) 
 select distinct on (a.huisnummer) huisnummer, 
 	s.vestigingsnaam naam,
 	s.onderwijsstructuur "type",
	s.denominatie,
	s.internetadres,
	s.straatnaam straat,
	a.huisletter,
	a.huisnummertoevoeging,
	replace(s.postcode, ' ', '') postcode,
	a.woonplaatsnaam plaats,
	s.gemeentenaam gemeente,
	s.provincie,
	s."instellingencode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (left(s.postcode,4)=left(a.postcode,4) 
             and s.straatnaam = a.openbareruimtenaam) 
				where a.gebruiksdoel like '%onderwijsfunctie%'
				and a.geopunt is not null;

-- SPECIAAL ONDERWIJS
-- speciaal onderwijs zonder huisnummer toevoegingen
insert into scholen
   select s.vestigingsnaam naam,
	soort_primair_onderwijs "type",
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
	s."instellingcode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from "09_alle_vestigingen_sbo_so_en_vs" s join bag20241122.bagadres a 
	    on (replace(s.postcode, ' ', '')=a.postcode and to_number(s.huisnummer_toevoeging,'99999')=a.huisnummer)
	     where s.huisnummer_toevoeging not like '%-%' and a.huisletter is null and a.huisnummertoevoeging is null;


-- met huisletter
insert into scholen
   select s.vestigingsnaam naam,
	soort_primair_onderwijs "type",
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
	s."instellingcode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from "09_alle_vestigingen_sbo_so_en_vs" s join bag20241122.bagadres a
      on (replace(s.postcode, ' ', '')=a.postcode and s.huisnummer_toevoeging ilike a.huisnummer::text || '-' || a.huisletter)
	     where s.huisnummer_toevoeging like '%-%' and a.huisletter is not null and a.huisnummertoevoeging is null;

-- met huisnummertoevoeging
insert into scholen
   select s.vestigingsnaam naam,
	soort_primair_onderwijs "type",
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
	s."instellingcode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
	  from "09_alle_vestigingen_sbo_so_en_vs" s join bag20241122.bagadres a
      on (replace(s.postcode, ' ', '')=a.postcode and s.huisnummer_toevoeging ilike a.huisnummer::text || '-' || a.huisnummertoevoeging)
	     where s.huisnummer_toevoeging like '%-%' and a.huisletter is null and a.huisnummertoevoeging is not null;

-- speciaal onderwijs: solve where straat numbers and housenumbers got mixed up
with ungeocodedvestigingen as
 (select a1.* 
  from "09_alle_vestigingen_sbo_so_en_vs" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
  soort_primair_onderwijs "type",
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
	s."instellingcode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and replace(s.straatnaam, ' ', '') || s.huisnummer_toevoeging ilike replace(a.openbareruimtenaam, ' ', '') || a.huisnummer::text || '-' || a.huisletter)
		      where s.huisnummer_toevoeging like '%-%' and a.huisletter is not null and a.geopunt is not null;


-- speciaal wijs: map house number ranges to first house number
with ungeocodedvestigingen as
 (select a1.* 
  from "09_alle_vestigingen_sbo_so_en_vs" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
  soort_primair_onderwijs "type",
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
	s."instellingcode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
		  on (replace(s.postcode, ' ', '')=a.postcode 
		    and to_number(regexp_replace(s.huisnummer_toevoeging, '([0-9]*)-([0-9]*)', '\1'),'9999') = a.huisnummer)
		      where a.huisletter is null and a.huisnummertoevoeging is null and a.geopunt is not null;

-- speciaal onderwijs: map house number ranges to first house number
with ungeocodedvestigingen as
 (select a1.* 
  from "09_alle_vestigingen_sbo_so_en_vs" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
  soort_primair_onderwijs "type",
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
	s."instellingcode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
			on ( replace(s.postcode, ' ', '')=a.postcode and to_number(regexp_replace(s.huisnummer_toevoeging, '([0-9]*)-([0-9]*)', '\2'),'9999') = a.huisnummer)
				where (regexp_match(s.huisnummer_toevoeging,'([0-9]*)-([0-9]*)'))[2] !='' 
					and a.huisletter is null 
					and a.huisnummertoevoeging is null 
					and a.geopunt is not null;

-- speciaal onderwijs: map housenumbers without extension to housennumbers with extension using onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from "09_alle_vestigingen_sbo_so_en_vs" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
  soort_primair_onderwijs "type",
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
	s."instellingcode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
			on (replace(s.postcode, ' ', '')=a.postcode 
		    and a.gebruiksdoel = 'onderwijsfunctie') and to_number(s.huisnummer_toevoeging, '99999')=a.huisnummer
		      where s.huisnummer_toevoeging not like '%-%' and a.geopunt is not null;


-- speciaal onderwijs: map on same postcode using onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from "09_alle_vestigingen_sbo_so_en_vs" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
  soort_primair_onderwijs "type",
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
	s."instellingcode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
			on (replace(s.postcode, ' ', '')=a.postcode 
		    and a.gebruiksdoel like '%onderwijsfunctie%')
		      where a.geopunt is not null;


-- speciaal onderwijs: map housenumbers without extension to house numbers with extension ignoring onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from "09_alle_vestigingen_sbo_so_en_vs" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
  soort_primair_onderwijs "type",
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
	s."instellingcode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
			on (replace(s.postcode, ' ', '')=a.postcode 
            ) and to_number(s.huisnummer_toevoeging, '99999')=a.huisnummer
		      where s.huisnummer_toevoeging not like '%-%' and a.geopunt is not null;


-- speciaal onderwijs: map on same street in same town using onderwijsfunctie
with ungeocodedvestigingen as
 (select a1.* 
  from "09_alle_vestigingen_sbo_so_en_vs" a1 left join scholen s1 on (a1.vestigingscode=s1.vestigingscode) 
    where s1.vestigingscode is null)
 insert into scholen
 select s.vestigingsnaam naam,
  soort_primair_onderwijs "type",
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
	s."instellingcode" brin_nummer,
	s.vestigingscode,
	s."onderwijsgebied_naam" onderwijsgebied,
	st_transform(a.geopunt,4326) locatie
		from ungeocodedvestigingen s left join bag20241122.bagadres a
			on (left(s.postcode,4)=left(a.postcode,4) 
             and s.straatnaam = a.openbareruimtenaam) 
				where a.gebruiksdoel like '%onderwijsfunctie%'
				and a.geopunt is not null;


