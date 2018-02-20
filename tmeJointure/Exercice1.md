# Exercice 1 :  Jointure entre 2 relations

## Question 1) jointure par hachage

### a)

On exécute d'abord la requête **R1** qui est la suivante:

```sql
explain plan for
  select /*+ ordered */ J.licence, C.nom
  from J, C
  where J.cnum = C.cnum
  and salaire >10;
@p4
```

L'exécution de la requête R1 nous donne l'affichage suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 2111974308

----------------------------------------------------------------
| Id  | Operation	   | Name | Rows  | Bytes | Cost (%CPU)|
----------------------------------------------------------------
|   0 | SELECT STATEMENT   |	  | 50000 |  1269K|    76   (2)|
|*  1 |  HASH JOIN	   |	  | 50000 |  1269K|    76   (2)|
|*  2 |   TABLE ACCESS FULL| J	  | 50000 |   683K|    68   (0)|
|   3 |   TABLE ACCESS FULL| C	  |  5000 | 60000 |	7   (0)|
----------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("J"."CNUM"="C"."CNUM")
   2 - filter("SALAIRE">10)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "J"."LICENCE"[NUMBER,22], "C"."NOM"[VARCHAR2,30]
   2 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22]
   3 - "C"."CNUM"[NUMBER,22], "C"."NOM"[VARCHAR2,30]
```

D'après cette affichage on peut observer que **le coût de la requête R1 est 76**.

On change maintenant l'ordre des tables dans la clause `WHERE`, pour lire la table C avant la table J. Donc notre requête devient le suivant:

```sql
explain plan for
  select /*+ ordered */ J.licence, C.nom
  from C, J
  where J.cnum = C.cnum
  and salaire >10;
@p4
```

L'affichage de cette requête donne la suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 1106137640

----------------------------------------------------------------
| Id  | Operation	   | Name | Rows  | Bytes | Cost (%CPU)|
----------------------------------------------------------------
|   0 | SELECT STATEMENT   |	  | 50000 |  1269K|    76   (2)|
|*  1 |  HASH JOIN	   |	  | 50000 |  1269K|    76   (2)|
|   2 |   TABLE ACCESS FULL| C	  |  5000 | 60000 |	7   (0)|
|*  3 |   TABLE ACCESS FULL| J	  | 50000 |   683K|    68   (0)|
----------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("J"."CNUM"="C"."CNUM")
   3 - filter("SALAIRE">10)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "C"."NOM"[VARCHAR2,30], "J"."LICENCE"[NUMBER,22]
   2 - "C"."CNUM"[NUMBER,22], "C"."NOM"[VARCHAR2,30]
   3 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22]
```

Comme on peut observer sur ces deux affichages la seule chose qui change c'est l'ordre des opérations `TABLE ACCESS FULL` des tables J et K. Sinon les coût des requêtes sont exactement le même.

**Remarque :** L'opérateur `/*+ ordered */` permet de fixer l'ordre de la lecture des tables comme elle sont passée dans la clause `FROM`.

### b)

On exécute d'abord la requête suivante:

```sql
explain plan for
	SELECT /*+ ordered */ *
	FROM C, BigJoueur j
	WHERE j.cnum = c.cnum;
@p4
```

L'exécution de cette requête donne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4081002869

---------------------------------------------------------------------
| Id  | Operation	   | Name      | Rows  | Bytes | Cost (%CPU)|
---------------------------------------------------------------------
|   0 | SELECT STATEMENT   |	       | 50000 |   193M| 13805	 (1)|
|*  1 |  HASH JOIN	   |	       | 50000 |   193M| 13805	 (1)|
|   2 |   TABLE ACCESS FULL| C	       |  5000 |   102K|     7	 (0)|
|   3 |   TABLE ACCESS FULL| BIGJOUEUR | 50000 |   192M| 13798	 (1)|
---------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("J"."CNUM"="C"."CNUM")

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "C"."CNUM"[NUMBER,22], "J"."CNUM"[NUMBER,22],
       "C"."VILLE"[VARCHAR2,30], "C"."NOM"[VARCHAR2,30],
       "C"."DIVISION"[NUMBER,22], "J"."LICENCE"[NUMBER,22],
       "J"."PROFIL"[VARCHAR2,4000], "J"."PRENOM"[VARCHAR2,30],
       "J"."SALAIRE"[NUMBER,22], "J"."SPORT"[VARCHAR2,30]
   2 - "C"."CNUM"[NUMBER,22], "C"."NOM"[VARCHAR2,30],
       "C"."DIVISION"[NUMBER,22], "C"."VILLE"[VARCHAR2,30]
   3 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22],
       "J"."PRENOM"[VARCHAR2,30], "J"."SALAIRE"[NUMBER,22],
       "J"."SPORT"[VARCHAR2,30], "J"."PROFIL"[VARCHAR2,4000]
```

D'après cette affichage on peut observer que le coùt de la requête est 13805.

Maintenant on l'inverse l'ordre des tables et on exécute la requête suivante:


```sql
explain plan for
	SELECT /*+ ordered */ *
	FROM  BigJoueur j, C
	WHERE j.cnum = c.cnum;
@p4
```

L'exécution de cette requête nous affiche la suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 3939046186

-----------------------------------------------------------------------------
| Id  | Operation	   | Name      | Rows  | Bytes |TempSpc| Cost (%CPU)|
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |	       | 50000 |   193M|       | 23370	 (1)|
|*  1 |  HASH JOIN	   |	       | 50000 |   193M|   192M| 23370	 (1)|
|   2 |   TABLE ACCESS FULL| BIGJOUEUR | 50000 |   192M|       | 13798	 (1)|
|   3 |   TABLE ACCESS FULL| C	       |  5000 |   102K|       |     7	 (0)|
-----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("J"."CNUM"="C"."CNUM")

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "J"."CNUM"[NUMBER,22], "C"."CNUM"[NUMBER,22],
       "J"."LICENCE"[NUMBER,22], "J"."PROFIL"[VARCHAR2,4000],
       "J"."PRENOM"[VARCHAR2,30], "J"."SALAIRE"[NUMBER,22],
       "J"."SPORT"[VARCHAR2,30], "C"."VILLE"[VARCHAR2,30],
       "C"."NOM"[VARCHAR2,30], "C"."DIVISION"[NUMBER,22]
   2 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22],
       "J"."PRENOM"[VARCHAR2,30], "J"."SALAIRE"[NUMBER,22],
       "J"."SPORT"[VARCHAR2,30], "J"."PROFIL"[VARCHAR2,4000]
   3 - "C"."CNUM"[NUMBER,22], "C"."NOM"[VARCHAR2,30],
       "C"."DIVISION"[NUMBER,22], "C"."VILLE"[VARCHAR2,30]
```

D'après cet affichage on peut observer que le coût de la requête est 23370 qui est beaucoup plus grand que le coût de la requête précédente qui était 13805. Cette différence remarquable vient de l'hachage. Dans la deuxième exécution la table d'hachage est relativement volimineux que la table d'hachage de l'exécution de la première requête. Comme c'est tellement volimineux on doit le stocker dans une espace de stockage temporaire qu'on peut le remarquer sur la colonne `TempSpc`. Juste cette opération de stocker dans une stockage temporaire est dans les ordres de 10 000. Cette différence de taille vient de l'algorithme d'hachage. Dans la première exécution on a 50 000 clé pour contenir 5000 valeurs ce qui est plutôt raisonnable mais pour la deuxième exécution on a 5000 clés pour stocker 50 000 valeurs et aussi ces valeurs sont des types Joueur qui est une type déjà volumineux.

### c)

On exécute maintenant les requêtes suivantes : 

- **R1**
```sql
explain plan for
	SELECT *
	FROM BigJoueur j
	WHERE j.salaire > 10;
@p4
```

L'affichage de cette requête nous affiche le suivant:
```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 476961767

--------------------------------------------------------------------
| Id  | Operation	  | Name      | Rows  | Bytes | Cost (%CPU)|
--------------------------------------------------------------------
|   0 | SELECT STATEMENT  |	      | 50000 |   192M| 13798	(1)|
|*  1 |  TABLE ACCESS FULL| BIGJOUEUR | 50000 |   192M| 13798	(1)|
--------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("J"."SALAIRE">10)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22],
       "J"."PRENOM"[VARCHAR2,30], "J"."SALAIRE"[NUMBER,22],
       "J"."SPORT"[VARCHAR2,30], "J"."PROFIL"[VARCHAR2,4000]
```

Comme on peut remarquer sur l'affichage de cette requête on peut voir que le nombre de la ligne affiché est 50000 qui le nombre des lignes total de la table et le coût de la requête est 13798.

- **R2**

```sql
explain plan for
	SELECT *
	FROM BigJoueur j
	WHERE j.salaire > 100;
@p4
```

- **R3**

```sql
explain plan for
	SELECT *
	FROM BigJoueur j
	WHERE j.salaire > 1000;
@p4
```

L'exécution de ces deux requête **R2** et **R3** donne exactement le même affichage que l'exécution de la requête **R1** ce qui veut dire qu'il n'y a aucun ligne pour que la valeur de la colonne salaire est plus petite que la 1000. Si on exécute la requête avec le prédicat `j.salaire > 10000`, c'est à dire que si on exécute la requête suivante:

```sql
explain plan for
	SELECT *
	FROM BigJoueur j
	WHERE j.salaire > 10000;
@p4
```

On obtient l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 476961767

--------------------------------------------------------------------
| Id  | Operation	  | Name      | Rows  | Bytes | Cost (%CPU)|
--------------------------------------------------------------------
|   0 | SELECT STATEMENT  |	      | 49998 |   192M| 13798	(1)|
|*  1 |  TABLE ACCESS FULL| BIGJOUEUR | 49998 |   192M| 13798	(1)|
--------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("J"."SALAIRE">10000)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22],
       "J"."PRENOM"[VARCHAR2,30], "J"."SALAIRE"[NUMBER,22],
       "J"."SPORT"[VARCHAR2,30], "J"."PROFIL"[VARCHAR2,4000]
```

Cette affichage nous montre qu'il y a seulement deux éléments Joueur dans la plage de salaire [1000,10000] et le plupart des lignes ont une valeur de salaire plus grand que 10 000.
 
Plus précisement, si on interroge la dictionnaire des indexes pour avoir plus d'information sur l'index sur salaire, en exécutant la requête suivante:

```sql
select index_name, distinct_keys, leaf_blocks
from user_indexes;
```

On obtient l'affichage suivante:

```sql
INDEX_NAME		       DISTINCT_KEYS LEAF_BLOCKS
------------------------------ ------------- -----------
I_C_CNUM				5000	       9
I_C_DIVISION				   2	      10
I_F_CNUM				5000	       9
I_J_CNUM				5000	     105
I_J_SALAIRE			       32188	     112

5 ligne(s) sélectionnée(s).
```

D'après cette affichage on peut observer que l'index sur salaire contient 32188 valeurs distintes sur 112 blocks. Examinons maintenant les valeurs min et max de salaire sur la table BigJoueur en exécutant la commande suivante:

```sql
 select min(salaire), max(salaire) 
 from BigJoueur;
```

On obtient l'affichage suivante:

```sql
MIN(SALAIRE) MAX(SALAIRE)
------------ ------------
       10000	    59996

1 ligne sélectionnée.
```

On peut observer que la valeur maximale de la salaire est 59996 et la valeur minimale des salaires est 10000, donc on peut observer que les 32188 différentes valeurs de salaires sont distribué sur la plage des valeurs [10000,59996] qui n'est pas une distribution uniforme. Cette distribution non uniforme implique sur le fait que le prédicat de sélection sur salaire n'est pas trop sélectif. On peut calculer le facteur de sélectivité par l'algorithme suivant:

```TypeScript
facteurDeSelectivite(valeurMin) {
    return (10000-valeurMin)/(59996-10000);
}
```

### d)

On exécute la commande suivante:

```sql
explain plan for
	SELECT J.licence, C.nom
	FROM C, j
	WHERE J.cnum = C.cnum
	AND salaire < 10050;
@p4
```

Cette exécution de cette requête donne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 17575486

---------------------------------------------------------------------------------
| Id  | Operation		     | Name	   | Rows  | Bytes | Cost (%CPU)|
---------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	     |		   |	50 |  1300 |	60   (2)|
|*  1 |  HASH JOIN		     |		   |	50 |  1300 |	60   (2)|
|   2 |   TABLE ACCESS BY INDEX ROWID| J	   |	50 |   700 |	52   (0)|
|*  3 |    INDEX RANGE SCAN	     | I_J_SALAIRE |	50 |	   |	 2   (0)|
|   4 |   TABLE ACCESS FULL	     | C	   |  5000 | 60000 |	 7   (0)|
---------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("J"."CNUM"="C"."CNUM")
   3 - access("SALAIRE"<10050)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "J"."LICENCE"[NUMBER,22], "C"."NOM"[VARCHAR2,30]
   2 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22]
   3 - "J".ROWID[ROWID,10]
   4 - "C"."CNUM"[NUMBER,22], "C"."NOM"[VARCHAR2,30]
```

D'après l'affichage et d'après l'algorithme de la facteur de sélectivité on peut dire que la facteur de sélectivité de cet prédicat est aux alenotours de 1% et il y a un 1% sur le coût de salaire qui vient de ROWID ce qui fait 2% le coût d'index.

On exécute maintenant la requête suivate:

```sql
explain plan for
	SELECT /*+ index(J I_J_SALAIRE ) */ J.licence, C.nom
	FROM C, j
	WHERE J.cnum = C.cnum
	AND salaire < 30000;
@p4
```

Cette exécution nous affiche l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 1734845739

---------------------------------------------------------------------------------
| Id  | Operation		     | Name	   | Rows  | Bytes | Cost (%CPU)|
---------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	     |		   | 20001 |   507K| 19966   (1)|
|*  1 |  HASH JOIN		     |		   | 20001 |   507K| 19966   (1)|
|   2 |   TABLE ACCESS FULL	     | C	   |  5000 | 60000 |	 7   (0)|
|   3 |   TABLE ACCESS BY INDEX ROWID| J	   | 20001 |   273K| 19959   (1)|
|*  4 |    INDEX RANGE SCAN	     | I_J_SALAIRE | 20001 |	   |	46   (0)|
---------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("J"."CNUM"="C"."CNUM")
   4 - access("SALAIRE"<30000)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "C"."NOM"[VARCHAR2,30], "J"."LICENCE"[NUMBER,22]
   2 - "C"."CNUM"[NUMBER,22], "C"."NOM"[VARCHAR2,30]
   3 - "J"."LICENCE"[NUMBER,22], "J"."CNUM"[NUMBER,22]
   4 - "J".ROWID[ROWID,10]
```

D'après l'algorithme du facteur de sélectivité qu'on a défini un peu plus en haut on peut dire que la facteur de sélectivité est aux alentours de 40% et il y 6% qui vient de **ROWID** sur le coût de cet index.






