# Exercice 1: Requête de sélection utilisant un index

 Expliquer le plan des requêtes suivantes. Détailler chaque étape de l'évaluation d'un plan.

## Question a)

```sql
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.age = 18;
@p3
```

## Explication a)

L'exécution du requête précédent nous donne l'affichage suivant.

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 771811286

-----------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  |
-----------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  |  2200 |
|   1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE |  2200 |
|*  2 |   INDEX RANGE SCAN	    | INDEXAGE	  |  2200 |
-----------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("A"."AGE"=18)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
   2 - "A".ROWID[ROWID,10]
```

Le plan du requête est le suivant:

- Le premier opération est le **SELECT STATEMENT** qui est le déclaration SELECT qui est au début du requête. Cet opération est affecté sur 2200 lignes.
- Le deuxième opération est le **TABLE ACCESS BY INDEX ROW ID**. D'après le documentation d'Oracle, cet opération récupère une ligne à partir de la table en utilisant le ROWID récupéré lors d'une recherche précédente dans l'index.
- Le dernier opération est le **INDEX RANGE SCAN**. Cet opération réalise un parcours du B-tree et suit la chaîne de nœuds feuilles pour trouver toutes les entrées correspon­dantes. Le début et le fin de cet opération est déterminé par le **prédicat d'access** qui est indiqué dans la section **Predicate Information** de l'affichage ci-dessus. Ce prédicat nous indique que le parcours de l'arbre est fait uniquement dans le cas de l'attribut âge est 18.

## Question b)

```sql
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.age BETWEEN 20 AND 29;
@p3
```

## Explication b)

L'exécution du requête précédent nous donne l'affichage suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 771811286

-----------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  |
-----------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  | 24400 |
|   1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE | 24400 |
|*  2 |   INDEX RANGE SCAN	    | INDEXAGE	  | 24400 |
-----------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("A"."AGE">=20 AND "A"."AGE"<=29)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
   2 - "A".ROWID[ROWID,10]
```

Cet affichage nous indique qu'il y a 3 opérations.

1. **SELECT STATEMENT** qui est la déclaration de SELECT au début du requête.
2. **TABLE ACCESS BY INDEX ROW ID** qui est comme  précédent permet d'accéder aux lignes de la table en utilisant l'index qui est crée par une recherche précédente.
3. **INDEX RANGE SCAN** qui réalise un parcours du B-Tree et suit la chaîne de noeuds feuilles pour trouver toutes les entrées correspondantes. Ce dernier est contrôlé par un prédicat qui est détaillé dans la section **Predicate Information** de l'affichage précédent. Ce prédicat est un prédicat d'accès qui permet de déterminer le début et la fin de recherche dans B-Tree. Dans notre cas, la recherche est fait uniquement sur les lignes dont la valeur du l'attribut âge est entre 20 (compris) et 29(compris).

## Question c)

```sql
explain plan for
   select a.nom, a.prenom
   from BigAnnuaire a
   where a.age < 70 and (a.cp = 93000 or a.cp = 75000);
@p3
```

## Explication c)

L'exécution de ce requête nous donne l'affichage suivant:

```sql
------------------------------------------------------------
| Id  | Operation		     | Name	   | Rows  |
------------------------------------------------------------
|   0 | SELECT STATEMENT	     |		   |   307 |
|   1 |  INLIST ITERATOR	     |		   |	   |
|*  2 |   TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE |   307 |
|*  3 |    INDEX RANGE SCAN	     | INDEXCP	   |   440 |
------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("A"."AGE"<70)
   3 - access("A"."CP"=75000 OR "A"."CP"=93000)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
   2 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
   3 - "A".ROWID[ROWID,10]
```

Cet affichage nous indique qu'il y 4 requêtes qui sont comme ceci:

1. **SELECT STATEMENT** qui est la déclaration SELECT qui détermine la nature du requête.
2. **INLIST ITERATOR** qui nous permet d'itérer entre des deux prédicats d'accès qui sont définis dans la section **Predicate Information**.
3. **TABLE ACCESS BY INDEX ROWID** a le même rôle que précédemment donc permet d'accéder aux lignes de la table en utilisant l'index qui est crée par une recherche précédente.
4. **INDEX RANGE SCAN** qui le même rôle que précédemment donc réalise un parcours du B-Tree et suit la chaîne de nœuds feuilles pour trouver toutes les entrées correspondantes. Ce dernier est contrôlé par un prédicat qui est détaillé dans la section **Predicate Information** de l'affichage précédent. Dans cet exemple on a deux prédicats différents. Notamment un **prédicat d'accès** et un **prédicat filter**. Le prédicat d'accès nous permet d'exprimer les condition pour le début et la fin du parcours de B-Tree et le prédicat filter, ici ne fait pas partie de l'index mais qui est sur une autre colonne de la table, qui permet de filtrer les données par rapport à son condition. Mais comme ici il ne fait pas partie de l'index mais une autre colonne de la table, la base des données doivent charger la ligne à partir de la table pour pouvoir ensuite appliquer le filtre au niveau de l'opération **TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE**

## Question d)

```sql
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age = 20 and a.cp = 13000 and a.nom like 'T%';
@p3
```

## Explication d)

L'exécution du requête précédent nous donne l'affichage suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 34588854

----------------------------------------------------------------
| Id  | Operation			 | Name        | Rows  |
----------------------------------------------------------------
|   0 | SELECT STATEMENT		 |	       |     1 |
|*  1 |  TABLE ACCESS BY INDEX ROWID	 | BIGANNUAIRE |     1 |
|   2 |   BITMAP CONVERSION TO ROWIDS	 |	       |       |
|   3 |    BITMAP AND			 |	       |       |
|   4 |     BITMAP CONVERSION FROM ROWIDS|	       |       |
|*  5 |      INDEX RANGE SCAN		 | INDEXCP     |   220 |
|   6 |     BITMAP CONVERSION FROM ROWIDS|	       |       |
|*  7 |      INDEX RANGE SCAN		 | INDEXAGE    |   220 |
----------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("A"."NOM" LIKE 'T%')
   5 - access("A"."CP"=13000)
   7 - access("A"."AGE"=20)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
   2 - "A".ROWID[ROWID,10]
   3 - STRDEF[BM VAR, 10], STRDEF[BM VAR, 10], STRDEF[BM VAR, 32496]
   4 - STRDEF[BM VAR, 10], STRDEF[BM VAR, 10], STRDEF[BM VAR, 32496]
   5 - "A".ROWID[ROWID,10]
   6 - STRDEF[BM VAR, 10], STRDEF[BM VAR, 10], STRDEF[BM VAR, 32496]
   7 - "A".ROWID[ROWID,10]
```

Ici on a 8 opérations comme suivant:

1. **SELECT STATEMENT** une déclaration de SELECT qui permet d'identifier la nature du requête.
2. **TABLE ACCES BY INDEX ROWID** une opération comme les précédentes, qui permet d'accéder aux lignes de la table en utilisant l'index qui est crée par une recherche précédente.
3. **BITMAP CONVERSION TO ROWIDS** permet de convertir les valeurs en BITMAP aux valeurs de type ROWID pour pouvoir l'accéder aux lignes.
4. **BITMAP AND** permet d'avoir un seul BITMAP en cumulant deux BITMAPs.
5. **BITMAP CONVERSION FROM ROWIDS** permet de convertir une valeur de type ROWIDS à une valeur de type BITMAP
6. **INDEX RANGE SCAN** réalise un parcours du B-Tree et suit la chaîne de nœuds feuilles pour trouver toutes les entrées correspondantes. Ce dernier est contrôlé par un prédicat qui est détaillé dans la section **Predicate Information** de l'affichage précédent.
7. **BITMAP CONVERSION FROM ROWIDS** permet de convertir une valeur de type ROWIDS à une valeur de type BITMAP
8. **INDEX RANGE SCAN** réalise un parcours du B-Tree et suit la chaîne de nœuds feuilles pour trouver toutes les entrées correspondantes. Ce dernier est contrôlé par un prédicat qui est détaillé dans la section **Predicate Information** de l'affichage précédent.

**REMARQUE :** Quand il y a plus de 1 prédicat d'accès, on doit trouver une solution pour créer un index en commun en suivant ces deux prédicats. Comme cet index ne peut pas être obtenu en cumulant simplement les index de type ROWID, Oracle  les convertit en BITMAP juste après l'exécution de l'operation, les cumule en tant que BITMAP pour avoir un index commun pour tous les prédicats d'accès et puis refait un transformation de type BITMAP au type ROWID pour avoir un index.

Les prédicats liés a ce requête sont :

- Il y a **deux prédicats d'accès** qui permettant de contrôler le début et le fin du parcours de B-Tree. L'un des deux prédicats détermine que le parcours sera fait uniquement  dans la condition que l'attribut CP est égale à 13000 et l'autre prédicat d'accès détermine que le parcours sera fait uniquement dans la condition que l'attribut AGE est égal à 20. (*Le passage par BITMAP nous permet d'avoir l'index sur les lignes dont l'attribut age est égale à 20 __et__ l'attribut CP est égale à 13000*)

**REMARQUE :** Oracle utilise deux index pour l'évaluation de cette requête et transforme la conjonction SQL (AND) en une intersection des adresses n-uplets (ROWID). Cette intersection est calculée par l'opérateur BITMAP AND sur un encodage binaire des ensembles d'adresses (en BITMAP).