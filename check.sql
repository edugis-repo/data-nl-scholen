-- ungeocoded vestigingen
select  	
    v.vestigingsnaam naam,
 	v.onderwijsstructuur type,
	v.denominatie,
	v.internetadres,
	v.straatnaam straat,
	v.huisnummer_toevoeging,
	replace(v.postcode, ' ', '') postcode,
	v.plaatsnaam plaats,
	v.gemeentenaam gemeente,
	v.provincie,
	v."brin nummer" brin_nummer,
	v.vestigingsnummer
  from public."02_alle_vestigingen_vo_utf8" v left join scholen s on (s.vestigingsnummer=v.vestigingsnummer) 
    where s.vestigingsnummer is null
union 
select
    v1.vestigingsnaam naam,
 	'basisschool' type,
	v1.denominatie,
	v1.internetadres,
	v1.straatnaam straat,
	v1.huisnummer_toevoeging,
	replace(v1.postcode, ' ', '') postcode,
	v1.plaatsnaam plaats,
	v1.gemeentenaam gemeente,
	v1.provincie,
	v1."brin nummer" brin_nummer,
	v1.vestigingsnummer
  from public."02_alle_schoolvestigingen_basisonderwijs_utf8" v1 left join scholen s1 on (v1.vestigingsnummer=s1.vestigingsnummer) 
    where s1.vestigingsnummer is null;
