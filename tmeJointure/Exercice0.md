# Exercice préliminaire

- Pour afficher le coût de la table J on exécute la requête suivante:

```sql
EXPLAIN plan FOR
SELECT * FROM J;
@p4
```

L'exécution de la requête affiche le suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 3339716715

---------------------------------------------------------------
| Id  | Operation	  | Name | Rows  | Bytes | Cost (%CPU)|
---------------------------------------------------------------
|   0 | SELECT STATEMENT  |	 | 50000 |  1464K|    68   (0)|
|   1 |  TABLE ACCESS FULL| J	 | 50000 |  1464K|    68   (0)|
---------------------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22],
       "J"."PRENOM"[VARCHAR2,30], "J"."SALAIRE"[NUMBER,22],
       "J"."SPORT"[VARCHAR2,30]
```

Cette affiche nous indique que **le coût de la table J est 68**.

- Pour afficher le coût de la table C on exécute la requête suivante:

```sql
explain plan for select * from C;
@p4
```

L'exécution de cette commande nous affiche l'affichage suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 2174124444

---------------------------------------------------------------
| Id  | Operation	  | Name | Rows  | Bytes | Cost (%CPU)|
---------------------------------------------------------------
|   0 | SELECT STATEMENT  |	 |  5000 |   102K|     7   (0)|
|   1 |  TABLE ACCESS FULL| C	 |  5000 |   102K|     7   (0)|
---------------------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "C"."CNUM"[NUMBER,22], "C"."NOM"[VARCHAR2,30],
       "C"."DIVISION"[NUMBER,22], "C"."VILLE"[VARCHAR2,30]
```

Cette affichage nous indique que **le coût de la table C est 7**.

- Pour afficher le coût de la table F on exécute la commande suivante:

```sql
explain plan for select * from F;
@p4
```

L'exécution de cette commande nous affiche le suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 1816606806

---------------------------------------------------------------
| Id  | Operation	  | Name | Rows  | Bytes | Cost (%CPU)|
---------------------------------------------------------------
|   0 | SELECT STATEMENT  |	 |  5000 | 65000 |     5   (0)|
|   1 |  TABLE ACCESS FULL| F	 |  5000 | 65000 |     5   (0)|
---------------------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "F"."CNUM"[NUMBER,22], "F"."BUDGET"[NUMBER,22],
       "F"."DEPENSE"[NUMBER,22], "F"."RECETTE"[NUMBER,22]
```

D'après cet affichage on peut remarquer que **le coût de la table F est 5**.

- Pour afficher le coût de la table BigJoueur on exécute la requête suivante:

```sql
explain plan for select * from BigJoueur;
@p4
```

L'exécution de cette commande nous donne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 476961767

--------------------------------------------------------------------
| Id  | Operation	  | Name      | Rows  | Bytes | Cost (%CPU)|
--------------------------------------------------------------------
|   0 | SELECT STATEMENT  |	      | 50000 |   192M| 13798	(1)|
|   1 |  TABLE ACCESS FULL| BIGJOUEUR | 50000 |   192M| 13798	(1)|
--------------------------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "BIGJOUEUR"."LICENCE"[NUMBER,22], "BIGJOUEUR"."CNUM"[NUMBER,22],
       "BIGJOUEUR"."PRENOM"[VARCHAR2,30], "BIGJOUEUR"."SALAIRE"[NUMBER,22],
       "BIGJOUEUR"."SPORT"[VARCHAR2,30], "BIGJOUEUR"."PROFIL"[VARCHAR2,4000]
```

D'après cette affichage on peut remarquer que **le coût de la table BigJoueur est 13798**.

