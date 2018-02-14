œ 

-- ===================
-- 3I009 2017
-- ===================

-- Compte rendu du TME 4-5 sur les plan d'exécution
-- ================================================

-- NOM, Prénom 1 : YAGCI Kaan
-- NOM, Prénom 2 :


-- Préparation : création de la relation Annuaire
-- ===========
@vider
@annuaire

@liste

-- schéma des relations :
desc Annuaire
desc BigAnnuaire


select count(*) as nb_personnes from BigAnnuaire;




-- Question préliminaire: Statistiques sur les tables
-- ==================================================

explain plan for
    select * from Annuaire;
@p3


explain plan for
    select * from BigAnnuaire;
@p3


explain plan for
    select distinct nom from BigAnnuaire;
@p3


explain plan for
    select distinct prenom from BigAnnuaire;
@p3


explain plan for
    select distinct age from BigAnnuaire;
@p3


explain plan for
    select distinct cp from BigAnnuaire;
@p3


select min(population), max(population)
from Ville;


-- =================================
-- Exercice 1 : Sélection avec index
-- =================================

-- a)
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age = 18;
@p3


-- b)
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age between 20 and 29;
@p3


-- c)
explain plan for
   select a.nom, a.prenom
   from BigAnnuaire a
   where a.age < 70 and (a.cp = 93000 or a.cp = 75000);
@p3


-- d)
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age = 20 and a.cp = 13000 and a.nom like 'T%';
@p3


-- Exercice 2: Sélection AVEC/SANS index
-- =====================================

-- a)
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age <= 10;
@p4

explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age <= 30;
@p4

explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age <= 40;
@p4

explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age <= 60;
@p4

explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age <= 80;
@p4


--COMPLETER




-- c)
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.cp BETWEEN 50000 AND COMPLETER;
@p4




-- Exercice 3. Comparaison de plans d'exécutions équivalents
-- =========================================================
explain plan for
   SELECT /*+  index( a IndexAge) */  a.nom, a.prenom 
   FROM BigAnnuaire a WHERE a.age < 7;
@p4


explain plan for
   SELECT /*+  no_index( a IndexAge) */   a.nom, a.prenom
   FROM BigAnnuaire a WHERE a.age < 7;
@p4

explain plan for
   SELECT   a.nom, a.prenom
   FROM BigAnnuaire a WHERE a.age < 7;
@p4


-- b)

explain plan for
   SELECT /*+  no_index( a IndexAge) */   a.nom, a.prenom
   FROM BigAnnuaire a WHERE a.age > 19;
@p4

explain plan for
   SELECT /*+  index( a IndexAge) */   a.nom, a.prenom
   FROM BigAnnuaire a WHERE a.age > 19;
@p4

explain plan for
   SELECT  a.nom, a.prenom
   FROM BigAnnuaire a WHERE a.age > 19;
@p4

--c)
explain plan for
    select /*+ index(a IndexAge) no_index(a IndexCp)  */  a.nom, a.prenom 
    from BigAnnuaire a where a.age = 18 and a.cp = 75000;
@p4

explain plan for
    select /*+ no_index(a IndexAge) index(a IndexCp)  */  a.nom, a.prenom 
    from BigAnnuaire a where a.age = 18 and a.cp = 75000;
@p4


explain plan for
    select /*+ index_combine(a IndexAge IndexCp)  */  a.nom, a.prenom 
    from BigAnnuaire a where a.age = 18 and a.cp = 75000;
@p4


explain plan for
    select /*+ no_index(a IndexAge) no_index(a IndexCp)  */  a.nom, a.prenom 
    from BigAnnuaire a where a.age = 18 and a.cp = 75000;
@p4


explain plan for
    select a.nom, a.prenom 
    from BigAnnuaire a where a.age = 18 and a.cp = 75000;
@p4





-- Exercice 4: Jointure avec index
-- ==================================

-- a) avec le "petit" Annuaire
explain plan for
    select a.nom, a.prenom, v.ville
    from Annuaire a, Ville v
    where a.cp = v.cp
    and a.age=18;
@p3


-- b) avec BigAnnuaire
explain plan for
    select a.nom, a.prenom, v.ville
    from BigAnnuaire a, Ville v
    where a.cp = v.cp
    and a.age=18;
@p3
    


--c)
explain plan for
    select a.nom, a.prenom, v.ville
    from BigAnnuaire a, Ville v
    where a.cp = v.cp
    and v.population >= 985000;
@p3




-- Exercice 5: Autres Requetes 
-- ===========================

--a Requêtes avec group by
EXPLAIN plan FOR
    SELECT age, COUNT(*)
    FROM BigAnnuaire a
    GROUP BY age;
@p3

--b Requêtes avec group by having
EXPLAIN plan FOR
    SELECT age, COUNT(*)
    FROM BigAnnuaire a
    GROUP BY age
    HAVING count(*) > 200;
@p3

--c Requête min max
EXPLAIN plan FOR
    SELECT MIN(cp), MAX(cp)
    FROM BigAnnuaire a;
@p3

--d Requête avec not in
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.prenom NOT IN ( SELECT b.prenom
                        FROM BigAnnuaire b
			WHERE b.age<=7);
@p3


--d.1 Sous-requête à l'intérieur de la requête de la question d
EXPLAIN plan FOR
SELECT b.prenom FROM BigAnnuaire b
WHERE b.age<=7;
@p3

--e Requête avec NOT EXISTS
    EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE NOT EXISTS ( SELECT *
                       FROM BigAnnuaire b
		       WHERE b.prenom = a.prenom
		       AND b.age < a.age);
@p3

--f Requête avec minus : les code spostaux des villes qui n'ont pas de centenaire. 

EXPLAIN plan FOR
  SELECT cp
  FROM BigAnnuaire a
  minus
   SELECT cp
   FROM BigAnnuaire b
   WHERE b.age>=100;
@p3

--f.1 Sous-requête de la question f)

EXPLAIN plan FOR
   SELECT cp
   FROM BigAnnuaire b
   WHERE b.age>=100;
@p3

--h Requête avec UNION, avec UNION ALL, avec une division, …

--h.1 Requêtes avec des opérateurs arithmétiques

--h.1.1 Requête avec l'opérateur `+` (unaire)

EXPLAIN plan FOR
SELECT +a.age 
FROM BigAnnuaire a;
@p3

--h.1.2 Requête avec l'opérateur `-` (unaire)

EXPLAIN plan FOR
SELECT -a.age
FROM BigAnnuaire a;
@p3

--h.1.3 Requête avec l'opérateur `/` (sur les dates et les nombres)

EXPLAIN plan FOR
SELECT a.age/100
FROM BigAnnuaire a;
@p3

--h.1.4 Requête avec l'opérateur `*`

EXPLAIN plan FOR
SELECT a.age * 100
FROM BigAnnuaire a;
@p3

--h.1.5 Requête avec l'opérateur `+`

EXPLAIN plan FOR
SELECT a.age + a.cp
FROM BigAnnuaire a;
@p3

--h.1.6 Requête avec l'opérateur `-`

EXPLAIN plan FOR
SELECT a.age - a.cp
FROM BigAnnuaire a;
@p3

--h.2 Requêtes avec des opérateurs sur les caractères

--h.2.1 Opérateur `||`

EXPLAIN plan FOR 
SELECT prenom||' '||nom
FROM BigAnnuaire;
@p3

--h.3 Requêtes avec des opérateurs de comparaison

--h.3.1 Opérateur `=`

EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age = 20;
@p3

--h.3.2 Opérateur `<>`

EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age <> 20;
@p3

--h.3.3 Opérateurs < et >

EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age > 20;
@p3


EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age < 20;
@p3

--h.3.4 Opérateurs <= et >=

EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age >= 20;
@p3


EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age <= 20;
@p3

--h.4.4 Opérateur IN

EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.prenom IN ( SELECT b.prenom
                        FROM BigAnnuaire b
			WHERE b.age<=7);
@p3


--h.4.7 Opérateur [NOT] BETWEEN

EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age
BETWEEN 1 AND 40;
@p3

EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age
NOT BETWEEN 1 AND 40;
@p3

--h.4.9 Opérateur [NOT] LIKE

EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.cp LIKE '75%';
@p3

--h.4.10 Opérateur IS [NOT] NULL

EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age IS NULL;
@p3


EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age IS NOT NULL;
@p3

-- Exercice 6: Documentation et Requetes sur le catalogue
-- ======================================================
COLUMN TABLE_NAME format A20
SELECT TABLE_NAME, blocks, num_rows 
FROM user_tables;


-- info sur la taille des index
column table_name format A10
column index_name format A10
--
select table_name, index_name, blevel, distinct_keys, leaf_blocks,
avg_leaf_blocks_per_key, avg_data_blocks_per_key
from user_indexes
where table_name = 'ANNUAIRE';

select table_name, index_name, blevel, distinct_keys, leaf_blocks,
avg_leaf_blocks_per_key, avg_data_blocks_per_key
from all_indexes
where table_name = 'BIGANNUAIRE';

