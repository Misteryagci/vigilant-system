# Exercice 3 Ordre des jointures entre 3 relations 

## Ordre1 : CFJ

```sql
explain plan for
    select /*+ ORDERED */ C.nom, F.budget 
    from C, F, J
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4
```

L'exécution de cette requête retourne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 2115463663

-----------------------------------------------------------------
| Id  | Operation	    | Name | Rows  | Bytes | Cost (%CPU)|
-----------------------------------------------------------------
|   0 | SELECT STATEMENT    |	   |	 1 |	40 |	82   (3)|
|*  1 |  HASH JOIN	    |	   |	 1 |	40 |	82   (3)|
|*  2 |   TABLE ACCESS FULL | J    |	 5 |	90 |	68   (0)|
|*  3 |   HASH JOIN	    |	   |  2500 | 55000 |	13   (8)|
|*  4 |    TABLE ACCESS FULL| C    |  2500 | 37500 |	 7   (0)|
|   5 |    TABLE ACCESS FULL| F    |  5000 | 35000 |	 5   (0)|
-----------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("J"."CNUM"="C"."CNUM" AND "J"."CNUM"="F"."CNUM")
   2 - filter("J"."SPORT"='sport1' AND "J"."SALAIRE">59000)
   3 - access("C"."CNUM"="F"."CNUM")
   4 - filter("C"."DIVISION"=1)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=2) "F"."BUDGET"[NUMBER,22], "C"."NOM"[VARCHAR2,30]
   2 - "J"."CNUM"[NUMBER,22]
   3 - (#keys=1) "C"."CNUM"[NUMBER,22], "F"."CNUM"[NUMBER,22],
       "C"."NOM"[VARCHAR2,30], "F"."BUDGET"[NUMBER,22]
   4 - "C"."CNUM"[NUMBER,22], "C"."NOM"[VARCHAR2,30]
   5 - "F"."CNUM"[NUMBER,22], "F"."BUDGET"[NUMBER,22]
```

Comme on peut observer sur ce plan d'exécution, on a les opérations suivantes:

1. `HASH JOIN` 
2. `TABLES ACCESS FULL` sur la table J
3. `HASH JOIN`
4. `TABLE ACCESS FULL` sur la table C
5. `TABLE ACCESS FULL` sur la table F.

La troisième opération, qui est de type `HASH JOIN` permet de créer une table d'hachage en utilisant les valeurs des opérations 4 et 5. Ceci permet de faire une première jointure dans l'ordre CF. Puis la première opération qui est type `HASH JOIN` permet de créer une table d'hachage en utilisant les valeurs de l'opération 2 et les valeurs de la table d'hachage consruite lors de l'opération 3. Avec cette opération on a bien l'ordre de jointures CFJ qui est l'ordre des tables dans la clause `FROM`.

## Ordre2 : CJF

```sql
explain plan for
    select /*+ ORDERED */ C.nom, F.budget 
    from C, J, F
    where J.cnum = C.cnum and C.cnum = F.cnum and J.cnum = F.cnum
    and C.division=1 and J.salaire > 59000
    and J.sport = 'sport1';
@p4
```

L'exécution de cette requête retourne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 578392453

------------------------------------------------------------------------------
| Id  | Operation		     | Name	| Rows	| Bytes | Cost (%CPU)|
------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	     |		|     1 |    40 |    81   (2)|
|   1 |  NESTED LOOPS		     |		|	|	|	     |
|   2 |   NESTED LOOPS		     |		|     1 |    40 |    81   (2)|
|*  3 |    HASH JOIN		     |		|     5 |   165 |    76   (2)|
|*  4 |     TABLE ACCESS FULL	     | C	|  2500 | 37500 |     7   (0)|
|*  5 |     TABLE ACCESS FULL	     | J	|     5 |    90 |    68   (0)|
|*  6 |    INDEX UNIQUE SCAN	     | I_F_CNUM |     1 |	|     0   (0)|
|   7 |   TABLE ACCESS BY INDEX ROWID| F	|     1 |     7 |     1   (0)|
------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("J"."CNUM"="C"."CNUM")
   4 - filter("C"."DIVISION"=1)
   5 - filter("J"."SPORT"='sport1' AND "J"."SALAIRE">59000)
   6 - access("J"."CNUM"="F"."CNUM")
       filter("C"."CNUM"="F"."CNUM")

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=0) "C"."NOM"[VARCHAR2,30], "F"."BUDGET"[NUMBER,22]
   2 - (#keys=0) "C"."NOM"[VARCHAR2,30], "F".ROWID[ROWID,10]
   3 - (#keys=1) "C"."CNUM"[NUMBER,22], "J"."CNUM"[NUMBER,22],
       "C"."NOM"[VARCHAR2,30]
   4 - "C"."CNUM"[NUMBER,22], "C"."NOM"[VARCHAR2,30]
   5 - "J"."CNUM"[NUMBER,22]
   6 - "F".ROWID[ROWID,10]
   7 - "F"."BUDGET"[NUMBER,22]
```
