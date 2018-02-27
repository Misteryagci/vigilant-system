-- NOM: YAGCI
-- Prénom: Kaan

-- ==========================
--      TME Jointure
-- ========================== 


-- Préparation
-- ===========

-- construire la base contenant les tables J, C et F
@vider
purge recyclebin;
@baseJCF

@liste


-- schéma des tables
desc J
desc C
desc F
desc BigJoueur



--afficher les cardinalités
select count(*) as nb_Joueurs from J;
select count(*) as nb_Clubs from C;
select count(*) as nb_Finances from F;
select count(*) as nb_BigJoueurs from BigJoueur;





-- =====================
-- Exercice préparatoire
-- =====================

explain plan for select * from J;
@p4

explain plan for select * from C;
@p4

explain plan for select * from F;
@p4

explain plan for select * from BigJoueur;
@p4



-- ============================================
--    Exercice 1: Jointure entre 2 relations
-- ============================================

-- Question 1
--===========

--a)
explain plan for
  select /*+ ordered */ J.licence, C.nom
  from J, C
  where J.cnum = C.cnum
  and salaire >10;
@p4

explain plan for
  select /*+ ordered */ J.licence, C.nom
  from C, J
  where J.cnum = C.cnum
  and salaire >10;
@p4

--b)

explain plan for
	SELECT /*+ ordered */ *
	FROM C, BigJoueur j
	WHERE j.cnum = c.cnum;
@p4

explain plan for
	SELECT /*+ ordered */ *
	FROM  BigJoueur j, C
	WHERE j.cnum = c.cnum;
@p4

-- c)

explain plan for
	SELECT *
	FROM BigJoueur j
	WHERE j.salaire > 10;
@p4

explain plan for
	SELECT *
	FROM BigJoueur j
	WHERE j.salaire > 100;
@p4

explain plan for
	SELECT *
	FROM BigJoueur j
	WHERE j.salaire > 1000;
@p4

explain plan for
	SELECT *
	FROM BigJoueur j
	WHERE j.salaire > 10000;
@p4

-- On peut dire qu'il y a 32188 valeurs distinctes et 112 blocks de l'index salaire 
select index_name, distinct_keys, leaf_blocks
from user_indexes;

 select min(salaire), max(salaire) from BigJoueur;

--d)

explain plan for
	SELECT J.licence, C.nom
	FROM C, j
	WHERE J.cnum = C.cnum
	AND salaire < 10050;
@p4

-- Question 2)
-- ===========

explain plan for
  select J.licence, C.nom
  from C, J
  where J.cnum = C.cnum
  and salaire < 11000;
@p4


-- Question 3)
-- ===========
explain plan for
  select J.licence, C.division
  from C, J
  where J.cnum = C.cnum
  and C.nom in ('PSG', 'Barca');
@p4


-- Question 4)
-- ===========
explain plan for
  select J.licence, C.division
  from C, J
  where J.cnum = C.cnum
  and J.salaire between 10000 and 10001;
@p4





-- ============================================================
-- EXERCICE 2: Directives USE_NL et USE_HASH pour une jointure
-- ============================================================



-- Question 1
--===========

explain plan for
  select /*+ USE_NL(J,C) */ J.licence, C.nom
  from J, C
  where J.cnum = C.cnum
  and salaire >10;
@p4


-- Question 2)
-- ===========

explain plan for
  select /*+ USE_NL(J,C) */ J.licence, C.nom
  from C, J
  where J.cnum = C.cnum
  and salaire < 11000;
@p4

explain plan for
  select /*+ USE_NL(J,C) */ J.licence, C.nom
  from C, J
  where salaire < 11000
  and J.cnum = C.cnum;
@p4


-- Question 3)
-- ===========

explain plan for
  select /*+ USE_HASH(C,J) */ J.licence, C.division
  from C, J
  where J.cnum = C.cnum
  and C.nom in ('PSG', 'Barca');
@p4

-- Question 4)
-- ===========
explain plan for
  select /*+ USE_HASH(J,C) */ J.licence, C.division
  from C, J
  where J.cnum = C.cnum
  and J.salaire between 10000 and 10001;
@p4






-- =====================================================
--   EXERCICE 3 : Ordre des jointures entre 3 relations 
-- =====================================================


-- ordre1 : CFJ
explain plan for
    select /*+ use_nl(J,C,F)  ORDERED */ C.nom, F.budget 
    from C, F, J
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre2 : CJF
explain plan for
    select /*+ use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from C, J, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre3 : FCJ
explain plan for
    select /*+ use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from F, C, J
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre4 : FJC
explain plan for
    select /*+ use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from F, J, C
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
--    where J.cnum = F.cnum and C.cnum = J.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre5 : JCF
explain plan for
    select /*+  use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- ordre6 : JFC
explain plan for
    select /*+  use_nl(J,C,F) ORDERED */ C.nom, F.budget 
    from J, F, C
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4



-- SANS directive ORDERED
explain plan for
    select  /*+  use_nl(J,C,F) */ C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4




-- avec directive index(J I_J_salaire)

explain plan for
    select /*+ use_nl(J,C,F) index(J I_J_salaire) */  C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4


-- avec directive  index(C I_C_division)

explain plan for
    select /*+  use_nl(J,C,F) index(C I_C_division) */  C.nom, F.budget 
    from J, C, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4

