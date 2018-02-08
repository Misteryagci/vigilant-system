# Exercice 3. Comparaison de plans d'exécutions équivalents

Pour une requête donnée, on veut étudier plusieurs plans équivalents afin de comparer le coût de chacun d'entre eux. Rappel pour afficher le coût, utiliser @p4

**Directive pour forcer/empêcher l'usage d'un index :**

Énumérer les plans équivalents revient à considérer toutes les combinaisons entre utiliser des index ou pas en ajoutant les directives index(Table Index) et no_index(Table Index) dans les requêtes SQL. Le 1er paramètre est le nom d'une table ou d'un alias déclaré dans la clause FROM. Le 2eme paramètre est le nom d'un index. La syntaxe est détaillée ci-dessous.

## Question a)

**Comparez deux plans équivalents pour la requête age < 7 qui est très sélective.**

- La directive index() force l'usage d'un index.

```sql
EXPLAIN plan FOR
   SELECT /*+ index(a IndexAge) */  a.nom, a.prenom
   FROM BigAnnuaire a WHERE a.age < 7;
@p4
```

- La directive no_index() empêche l'usage d'un index:

```sql
EXPLAIN plan FOR
   SELECT /*+  no_index(a IndexAge) */  a.nom, a.prenom
   FROM BigAnnuaire a WHERE a.age < 7;
@p4
```

 Vérifier que le plan de coût minimal est bien celui choisi sans aucune directive.

## Réponse a)

- L'exécution de la première requête donne l'affichage suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 771811286

--------------------------------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  | Bytes | Cost (%CPU)|
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  | 13333 |   234K| 13365   (1)|
|   1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE | 13333 |   234K| 13365   (1)|
|*  2 |   INDEX RANGE SCAN	    | INDEXAGE	  | 13333 |	  |    28   (0)|
--------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("A"."AGE"<7)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
   2 - "A".ROWID[ROWID,10]
```

- L'exécution de la deuxième requête donne l'affichage suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4247486214

----------------------------------------------------------------------
| Id  | Operation	  | Name	| Rows	| Bytes | Cost (%CPU)|
----------------------------------------------------------------------
|   0 | SELECT STATEMENT  |		| 13333 |   234K| 70893   (1)|
|*  1 |  TABLE ACCESS FULL| BIGANNUAIRE | 13333 |   234K| 70893   (1)|
----------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("A"."AGE"<7)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
```

Par rapport a ces deux exécutions, on peut remarquer que l'utilisation d'un index optimise le coût de la requête, et diminuant le nombre des lignes parcouru par la requête.

Si on exécute la même commande mais sans aucune **directive** c'est à dire la requête suivante:

```sql
explain plan for
   SELECT a.nom, a.prenom
   FROM BigAnnuaire a WHERE a.age < 7;
@p4
```

On obtient l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 771811286

--------------------------------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  | Bytes | Cost (%CPU)|
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  | 13333 |   234K| 13365   (1)|
|   1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE | 13333 |   234K| 13365   (1)|
|*  2 |   INDEX RANGE SCAN	    | INDEXAGE	  | 13333 |	  |    28   (0)|
--------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("A"."AGE"<7)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
   2 - "A".ROWID[ROWID,10]
```

Comme on peut remarquer cette dernière affichage est la même que l'affichage du requête en utilisant la **directive  index( a IndexAge)**. Alors on peut en déduire que l'utilisation d'un index permet de réduire le coût de cette requête, et c'est pour ça sans utiliser aucun directives, Oracle utilise un index **IndexAge** pour optimiser le coût de la requête.

## Question b)

**Idem pour la requête age > 19 qui est peu sélective.**

On exécute ces trois requêtes suivantes:

1. En utilisant la **directive**  no_index pour forcer Oracle de ne pas utiliser un index.
    ```sql
    explain plan for
    SELECT /*+  no_index( a IndexAge) */   a.nom, a.prenom
    FROM BigAnnuaire a WHERE a.age > 19;
    @p4
    ```
2. En utilisant la **directive** index pour forcer Oracle à utiliser un index.
    ```sql
    explain plan for
    SELECT /*+  index( a IndexAge) */   a.nom, a.prenom
    FROM BigAnnuaire a WHERE a.age > 19;
    @p4
    ```
3. En utilisant **aucun directive** pour laisser Oracle à traiter le requête.
    ```sql
    explain plan for
    SELECT  a.nom, a.prenom
    FROM BigAnnuaire a WHERE a.age > 19;
    @p4
    ```
A l'exécution de ces trois requêtes on obtiens ces trois affichages suivantes:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4247486214

----------------------------------------------------------------------
| Id  | Operation	  | Name	| Rows	| Bytes | Cost (%CPU)|
----------------------------------------------------------------------
|   0 | SELECT STATEMENT  |		|   180K|  3164K| 70893   (1)|
|*  1 |  TABLE ACCESS FULL| BIGANNUAIRE |   180K|  3164K| 70893   (1)|
----------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

1 - filter("A"."AGE">19)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
```

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 771811286

--------------------------------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  | Bytes | Cost (%CPU)|
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  |   180K|  3164K|   180K  (1)|
|   1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE |   180K|  3164K|   180K  (1)|
|*  2 |   INDEX RANGE SCAN	    | INDEXAGE	  |   180K|	  |   354   (1)|
--------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

2 - access("A"."AGE">19)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
2 - "A".ROWID[ROWID,10]
```

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4247486214

----------------------------------------------------------------------
| Id  | Operation	  | Name	| Rows	| Bytes | Cost (%CPU)|
----------------------------------------------------------------------
|   0 | SELECT STATEMENT  |		|   180K|  3164K| 70893   (1)|
|*  1 |  TABLE ACCESS FULL| BIGANNUAIRE |   180K|  3164K| 70893   (1)|
----------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("A"."AGE">19)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
```

On peut observer que comme la condition `age>19` est peu selective, l'utilisation d'un index ne diminue pas le coût mais augmente le coût de l'exécution de la requête. C'est pour ça aussi sans aucun directive Oracle préfère de parcourir tout la table et de filtrer au lieu d'utiliser un index.

## Question c)

**Pour la requête `age = 18 and cp = 75000` proposer 4 plans équivalents et donner leur coût. Vérifier que le plan de coût minimal est bien celui choisi sans aucune directive.**

- Pour forcer l'index **IndexAge** et empêcher l'index **IndexCP** dans une même requête :
    ```sql
    EXPLAIN plan FOR
        SELECT /*+ index(a IndexAge) no_index(a IndexCp)  */  a.nom, a.prenom
        FROM BigAnnuaire a WHERE a.age = 18 AND a.cp = 75000;
    @p4
    ```
- Pour forcer l'index **IndexCp** et empêcher l'index **IndexAge** dans une même requête :
    ```sql
    EXPLAIN plan FOR
        SELECT /*+ index(a IndexCp) no_index(a IndexAge)  */  a.nom, a.prenom
        FROM BigAnnuaire a WHERE a.age = 18 AND a.cp = 75000;
    @p4
    ```
- Pour forcer les deux index **IndexCp** et **IndexAge** dans une même requête :
    ```sql
    EXPLAIN plan FOR
        select /*+ index_combine(a IndexAge IndexCp)  */  a.nom, a.prenom
        from BigAnnuaire a where a.age = 18 and a.cp = 75000;
    @p4
    ```
- Pour empêcher les deux index **IndexCp** et **IndexAge** dans une même requête :
    ```sql
    EXPLAIN plan FOR
        SELECT /*+ no_index(a IndexCp) no_index(a IndexAge)  */  a.nom, a.prenom
        FROM BigAnnuaire a WHERE a.age = 18 AND a.cp = 75000;
    @p4
    ```

- L'exécution de la première requête rend l'affichage suivante:
    ```sql
    PLAN_TABLE_OUTPUT
    ----------------------------------------------------------------------------------------------------
    Plan hash value: 771811286

    --------------------------------------------------------------------------------
    | Id  | Operation		    | Name	  | Rows  | Bytes | Cost (%CPU)|
    --------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT	    |		  |	2 |    44 |  2206   (1)|
    |*  1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE |	2 |    44 |  2206   (1)|
    |*  2 |   INDEX RANGE SCAN	    | INDEXAGE	  |  2200 |	  |	5   (0)|
    --------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

    1 - filter("A"."CP"=75000)
    2 - access("A"."AGE"=18)

    Column Projection Information (identified by operation id):
    -----------------------------------------------------------

    1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
    2 - "A".ROWID[ROWID,10]
    ```
- L'exécution de la deuxième requête rend l'affichage suivante :
    ```sql
    PLAN_TABLE_OUTPUT
    ----------------------------------------------------------------------------------------------------
    Plan hash value: 1858303794

    --------------------------------------------------------------------------------
    | Id  | Operation		    | Name	  | Rows  | Bytes | Cost (%CPU)|
    --------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT	    |		  |	2 |    44 |   221   (0)|
    |*  1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE |	2 |    44 |   221   (0)|
    |*  2 |   INDEX RANGE SCAN	    | INDEXCP	  |   220 |	  |	1   (0)|
    --------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

    1 - filter("A"."AGE"=18)
    2 - access("A"."CP"=75000)

    Column Projection Information (identified by operation id):
    -----------------------------------------------------------

    1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
    2 - "A".ROWID[ROWID,10]
    ```
- L'exécution de le troisième requête rend l'affichage suivante :
    ```sql
    PLAN_TABLE_OUTPUT
    ----------------------------------------------------------------------------------------------------
    Plan hash value: 34588854

    -------------------------------------------------------------------------------------
    | Id  | Operation			 | Name        | Rows  | Bytes | Cost (%CPU)|
    -------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT		 |	       |     2 |    44 |    10	 (0)|
    |   1 |  TABLE ACCESS BY INDEX ROWID	 | BIGANNUAIRE |     2 |    44 |    10	 (0)|
    |   2 |   BITMAP CONVERSION TO ROWIDS	 |	       |       |       |	    |
    |   3 |    BITMAP AND			 |	       |       |       |	    |
    |   4 |     BITMAP CONVERSION FROM ROWIDS|	       |       |       |	    |
    |*  5 |      INDEX RANGE SCAN		 | INDEXCP     |       |       |     1	 (0)|
    |   6 |     BITMAP CONVERSION FROM ROWIDS|	       |       |       |	    |
    |*  7 |      INDEX RANGE SCAN		 | INDEXAGE    |       |       |     5	 (0)|
    -------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

    5 - access("A"."CP"=75000)
    7 - access("A"."AGE"=18)

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
- L'exécution de la quatrième et la dernière requête rend l'affichage suivante:
    ```sql
    PLAN_TABLE_OUTPUT
    ----------------------------------------------------------------------------------------------------
    Plan hash value: 4247486214

    ----------------------------------------------------------------------
    | Id  | Operation	  | Name	| Rows	| Bytes | Cost (%CPU)|
    ----------------------------------------------------------------------
    |   0 | SELECT STATEMENT  |		|     2 |    44 | 70893   (1)|
    |*  1 |  TABLE ACCESS FULL| BIGANNUAIRE |     2 |    44 | 70893   (1)|
    ----------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

    1 - filter("A"."CP"=75000 AND "A"."AGE"=18)

    Column Projection Information (identified by operation id):
    -----------------------------------------------------------

    1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
    ```
D'après ces quatres exécutions on peut dire qu'on obtient un meilleur coût en forçant l'utilisation des deux indexes. Dans le deuxième rang des meilleurs coût on n'a la deuxième requête qui est la requête que l'utilisation de l'index IndexAge est forcé mais l'utilisation de l'index IndexCp est empêché, puis dans le troisième rang on a la première requête dans laquelle on a forcé l'utilisation de l'index IndexCp et on a empêché l'utilisation de l'index IndexAge. Et dans le dernier rang on a la dernière requête qu'on a empêché l'utilisation des deux index.

Si on n'utilise aucun directive, c'est à dire qu'on exécute la commande suivante:

```sql
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a where a.age = 18 and a.cp = 75000;
@p4
```

On obtient l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 34588854

-------------------------------------------------------------------------------------
| Id  | Operation			 | Name        | Rows  | Bytes | Cost (%CPU)|
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT		 |	       |     2 |    44 |    10	 (0)|
|   1 |  TABLE ACCESS BY INDEX ROWID	 | BIGANNUAIRE |     2 |    44 |    10	 (0)|
|   2 |   BITMAP CONVERSION TO ROWIDS	 |	       |       |       |	    |
|   3 |    BITMAP AND			 |	       |       |       |	    |
|   4 |     BITMAP CONVERSION FROM ROWIDS|	       |       |       |	    |
|*  5 |      INDEX RANGE SCAN		 | INDEXCP     |   220 |       |     1	 (0)|
|   6 |     BITMAP CONVERSION FROM ROWIDS|	       |       |       |	    |
|*  7 |      INDEX RANGE SCAN		 | INDEXAGE    |   220 |       |     5	 (0)|
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - access("A"."CP"=75000)
   7 - access("A"."AGE"=18)

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

D'après cette affichage on peut en déduire que Oracle a utilisé les deux index pour obtenir un meilleur coût de l'exécution.

**Remarque:** Déclarer plusieurs directives index(..,…) ne force pas à utiliser les plusieurs index simultanément, mais force à en utiliser un (le meilleur). Voir plutôt index_combine ou index_join pour cela https://docs.oracle.com/cd/B10501_01/server.920/a96533/hintsref.htm#5215