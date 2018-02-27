# Exercice 2

## Question 1

Soit la requête R3

```sql
explain plan for
  select /*+ USE_NL(J,C) */ J.licence, C.nom
  from J, C
  where J.cnum = C.cnum
  and salaire >10;
@p4
```

L'exécution de cette requête retourne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 3996619973

------------------------------------------------------------------------------
| Id  | Operation		     | Name	| Rows	| Bytes | Cost (%CPU)|
------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	     |		| 50000 |  1269K| 50083   (1)|
|   1 |  NESTED LOOPS		     |		|	|	|	     |
|   2 |   NESTED LOOPS		     |		| 50000 |  1269K| 50083   (1)|
|*  3 |    TABLE ACCESS FULL	     | J	| 50000 |   683K|    68   (0)|
|*  4 |    INDEX UNIQUE SCAN	     | I_C_CNUM |     1 |	|     0   (0)|
|   5 |   TABLE ACCESS BY INDEX ROWID| C	|     1 |    12 |     1   (0)|
------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("SALAIRE">10)
   4 - access("J"."CNUM"="C"."CNUM")

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=0) "J"."LICENCE"[NUMBER,22], "C"."NOM"[VARCHAR2,30]
   2 - (#keys=0) "J"."LICENCE"[NUMBER,22], "C".ROWID[ROWID,10]
   3 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22]
   4 - "C".ROWID[ROWID,10]
   5 - "C"."NOM"[VARCHAR2,30]
SQL> 
```

- L'opération **INDEX UNIQUE SCAN** permet de parcourir le B-Tree en utilisant l'index **I_C_CNUM** et le prédicat d'accès **`access("J"."CNUM"="C"."CNUM")`**. Ce parcours consiste à sélectionner les valeurs uniques dans le B-Tree.
- L'opération **TABLE ACCESS FULL** permet de parcourir tout la table en parcourant toutes les lignes et toutes les colonnes. Ce parcours est filtré par le prédicat de type FILTER `filter("SALAIRE">10)` qui permet de sélectionner les lignes dont la valeurs à la colonne **SALAIRE** est plus grand que 10.
- Ces deux parcours précédents sont fait en tant que boucles imbriqués. Ceci est indiqué par la présence de l'opération **NESTED LOOPS**.
- L'opération **TABLE ACCESS BY INDEX ROWID** permet de parcourir les valeurs d'un index précédent par le numéro de ligne. L'index utilisé pour cette opération est l'index utilisé dans l'opération **INDEX UNIQUE SCAN** qui est `I_C_CNUM`.
- Le boucle imbriqué expliqué ci-dessus et l'opération **TABLE ACCESS BY INDEX ROWID** expliqué ci-dessus sont exécuté en tant que les boucles imbriquées, ceci est indiqué par la présence de l'opération **NESTED LOOPS**.
- Ces deux opérations **NESTED LOOPS** est forcé par l'utilisation de l'opération ` /*+ USE_NL(J,C) */` qui force l'utilisation des opérations **NESTED LOOPS** sur les tables J et C.


## Question 2

```sql
explain plan for
  select /*+ USE_NL(J,C) */ J.licence, C.nom
  from C, J
  where J.cnum = C.cnum
  and salaire < 11000;
@p4
```

L'exécution de cette requête retourne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 3996619973

------------------------------------------------------------------------------
| Id  | Operation		     | Name	| Rows	| Bytes | Cost (%CPU)|
------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	     |		|  1000 | 26000 |  1069   (1)|
|   1 |  NESTED LOOPS		     |		|	|	|	     |
|   2 |   NESTED LOOPS		     |		|  1000 | 26000 |  1069   (1)|
|*  3 |    TABLE ACCESS FULL	     | J	|  1000 | 14000 |    68   (0)|
|*  4 |    INDEX UNIQUE SCAN	     | I_C_CNUM |     1 |	|     0   (0)|
|   5 |   TABLE ACCESS BY INDEX ROWID| C	|     1 |    12 |     1   (0)|
------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("SALAIRE"<11000)
   4 - access("J"."CNUM"="C"."CNUM")

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=0) "J"."LICENCE"[NUMBER,22], "C"."NOM"[VARCHAR2,30]
   2 - (#keys=0) "J"."LICENCE"[NUMBER,22], "C".ROWID[ROWID,10]
   3 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22]
   4 - "C".ROWID[ROWID,10]
   5 - "C"."NOM"[VARCHAR2,30]
```

Comme dans la question précédente l'utilisation de l'opération `/*+ USE_NL(J,C) */` force l'utilisation des opérations **NESTED LOOPS** sur les tables J et C. L'ordre des tables dans la clause `WHERE` ni dans l'opération `/*+ USE_NL(J,C) */` ne change pas l'ordre des opérations **NESTED LOOPS**.

## Question 3

On exécute la requête suivante :

```sql
explain plan for
  select /*+ USE_HASH(J,C) */ J.licence, C.division
  from C, J
  where J.cnum = C.cnum
  and C.nom in ('PSG', 'Barca');
@p4
```

L'exécution de cette requête nous retourne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 1106137640

----------------------------------------------------------------
| Id  | Operation	   | Name | Rows  | Bytes | Cost (%CPU)|
----------------------------------------------------------------
|   0 | SELECT STATEMENT   |	  |    15 |   360 |    76   (2)|
|*  1 |  HASH JOIN	   |	  |    15 |   360 |    76   (2)|
|*  2 |   TABLE ACCESS FULL| C	  |	2 |    30 |	7   (0)|
|   3 |   TABLE ACCESS FULL| J	  | 50000 |   439K|    68   (0)|
----------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("J"."CNUM"="C"."CNUM")
   2 - filter("C"."NOM"='Barca' OR "C"."NOM"='PSG')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "C"."DIVISION"[NUMBER,22], "J"."LICENCE"[NUMBER,22]
   2 - "C"."CNUM"[NUMBER,22], "C"."DIVISION"[NUMBER,22]
   3 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22]
```

- L'utilisation de l'opération `/*+ USE_HASH(J,C) */` force l'utilisation de l'opération **HASH JOIN** qui permet de créer une table d'hachage en utilisant les valeurs de la table C et de la table J obtenu par les opérations **TABLE ACCESS FULL** id 2 sur la table C et l'opération **TABLE ACCESS FULL** id 3 sur la table J. L'opération **TABLE ACCESS FULL** d'id 2 est filtré par le prédicat de type filter `filter("C"."NOM"='Barca' OR "C"."NOM"='PSG')` ainsi l'opération `HASH JOIN` est faite en utilisant un prédicat d'accès `access("J"."CNUM"="C"."CNUM")` qui permet de construire la table d'hachage par les valeurs de deux tables sur les mêmes valeurs `CNUM`.

## Question 4

On exécute maintenant la requête suivante:

```sql
explain plan for
  select /*+ USE_HASH(J,C) */ J.licence, C.division
  from C, J
  where J.cnum = C.cnum
  and J.salaire between 10000 and 10001;
@p4
```

L'exécution de cette requête nous retourne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 17575486

---------------------------------------------------------------------------------
| Id  | Operation		     | Name	   | Rows  | Bytes | Cost (%CPU)|
---------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	     |		   |	 3 |	63 |	13   (8)|
|*  1 |  HASH JOIN		     |		   |	 3 |	63 |	13   (8)|
|   2 |   TABLE ACCESS BY INDEX ROWID| J	   |	 3 |	42 |	 5   (0)|
|*  3 |    INDEX RANGE SCAN	     | I_J_SALAIRE |	 3 |	   |	 2   (0)|
|   4 |   TABLE ACCESS FULL	     | C	   |  5000 | 35000 |	 7   (0)|
---------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("J"."CNUM"="C"."CNUM")
   3 - access("J"."SALAIRE">=10000 AND "J"."SALAIRE"<=10001)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "J"."LICENCE"[NUMBER,22], "C"."DIVISION"[NUMBER,22]
   2 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22]
   3 - "J".ROWID[ROWID,10]
   4 - "C"."CNUM"[NUMBER,22], "C"."DIVISION"[NUMBER,22]
```

- Comme la question précédente l'utilisation de l'opération `/*+ USE_HASH(J,C) */` force l'utilisation de l'opération `HASH JOIN` mais cette fois ci la table d'hachage contient les valeurs obtenu par l'opération **TABLE ACCESS BY INDEX ROWID** sur l'index `I_J_SALAIRE` et les valeurs obtenu par l'opération **TABLES ACCESS FULL** sur la table C. Cet index `I_J_SALAIRE` contient les valeurs salaire entre 10000 et 10001.

**Remarque :** L'ordre de construction de la table d'hachage dépend de l'ordre de jointure dans la clause `WHERE` mais pas de l'ordre dans l'opération `/*+ USE_HASH(J,C) */`.

