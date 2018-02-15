# Exercice 2 : Sélection AVEC OU SANS index

Dans les plans suivants, on affiche son coût (voir la colonne Cost)

## Question a)

Étudiez plusieurs variantes de la requête sélectionnant les personnes dont l'âge est inférieur à une valeur donnée. Pour cela, testez les prédicats de la forme age < = A avec A valant 10, 30, 40, 60 et 80.

```sql
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age <= 10;
@p4
```

### Affichage pour `age <= 10`

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 771811286

--------------------------------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  | Bytes | Cost (%CPU)|
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  | 22200 |   390K| 22250   (1)|
|   1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE | 22200 |   390K| 22250   (1)|
|*  2 |   INDEX RANGE SCAN	    | INDEXAGE	  | 22200 |	  |    45   (0)|
--------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("A"."AGE"<=10)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
   2 - "A".ROWID[ROWID,10]
```

```sql
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age <= 30;
@p4
```

### Affichage pour `age <= 30`

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 771811286

--------------------------------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  | Bytes | Cost (%CPU)|
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  | 66644 |  1171K| 66793   (1)|
|   1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE | 66644 |  1171K| 66793   (1)|
|*  2 |   INDEX RANGE SCAN	    | INDEXAGE	  | 66644 |	  |   132   (0)|
--------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("A"."AGE"<=30)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
   2 - "A".ROWID[ROWID,10]
```

```sql
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age <= 40;
@p4
```

### Affichage pour `age <= 40`

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4247486214

----------------------------------------------------------------------
| Id  | Operation	  | Name	| Rows	| Bytes | Cost (%CPU)|
----------------------------------------------------------------------
|   0 | SELECT STATEMENT  |		| 88867 |  1562K| 70893   (1)|
|*  1 |  TABLE ACCESS FULL| BIGANNUAIRE | 88867 |  1562K| 70893   (1)|
----------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("A"."AGE"<=40)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
```

```sql
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age <= 60;
@p4
```

### Affichage `age <= 60`

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4247486214

----------------------------------------------------------------------
| Id  | Operation	  | Name	| Rows	| Bytes | Cost (%CPU)|
----------------------------------------------------------------------
|   0 | SELECT STATEMENT  |		|   133K|  2343K| 70893   (1)|
|*  1 |  TABLE ACCESS FULL| BIGANNUAIRE |   133K|  2343K| 70893   (1)|
----------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("A"."AGE"<=60)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
```

```sql
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age <= 80;
@p4
```

### Affichage `age <= 80`

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4247486214

----------------------------------------------------------------------
| Id  | Operation	  | Name	| Rows	| Bytes | Cost (%CPU)|
----------------------------------------------------------------------
|   0 | SELECT STATEMENT  |		|   177K|  3124K| 70893   (1)|
|*  1 |  TABLE ACCESS FULL| BIGANNUAIRE |   177K|  3124K| 70893   (1)|
----------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("A"."AGE"<=80)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
```

Compléter le tableau en indiquant la cardinalité, le coût et si l'index IndexAge est utilisé ou non.

| Prédicat | Rows |  Index utilisé | Cout |
|:--------:|:----:|:--------------:|:----:|
| **age <= 10** | 22200 | oui | 22250 |
| **age <= 30** | 66644 | oui | 66793 |
| **age <= 40** | 88867 |  non | 70893 |
| **age <= 60** | 133 000 | non | 70893 |
| **age <= 80** | 177 000 | non | 70893 |

## Question b)

**Pour quel prédicat Oracle préfère-t-il évaluer la requête sans utiliser l'index IndexAge ? Pourquoi ?**

## Réponse b)

Oracle évalue les requêtes `age <= 40`,`age <= 60`, `age <= 80` sans utiliser l'index IndexAge. Parce que le nombre des lignes retourné par ces prédicats sont tellement important que l'Oracle par défaut préfère de parcourir tout la table de filtrer les données en utilisant ces prédicats qu'utiliser des indexes et les manipuler. C'est un optimisation que l'Oracle fait automatiquement.

## Question c)

**Proposer deux requêtes `BETWEEN 50000 AND …` sélectionnant un intervalle de valeurs du code postal comprises entre 50000 et N.**

- **la première utilise l'index IndexCP,**
- **la deuxième ne l'utilise pas.**

## Réponse c)

- La requête suivant utilise l'index IndexCP:
    ```sql
    explain plan for
        select a.nom, a.prenom
        from BigAnnuaire a
        where a.cp BETWEEN 50000 AND 50001;
    @p4
    ```
    **Affichage**

    ```sql
    PLAN_TABLE_OUTPUT
    ----------------------------------------------------------------------------------------------------
    Plan hash value: 1858303794

    --------------------------------------------------------------------------------
    | Id  | Operation		    | Name	  | Rows  | Bytes | Cost (%CPU)|
    --------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT	    |		  |   442 |  8398 |   445   (0)|
    |   1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE |   442 |  8398 |   445   (0)|
    |*  2 |   INDEX RANGE SCAN	    | INDEXCP	  |   442 |	  |	2   (0)|
    --------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

    2 - access("A"."CP">=50000 AND "A"."CP"<=50001)

    Column Projection Information (identified by operation id):
    -----------------------------------------------------------

    1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
    2 - "A".ROWID[ROWID,10]
    SQL>
    ```
- La requête suivante n'utilise pas l'index IndexCP:

    ```sql
    explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.cp BETWEEN 50000 AND 9999999;
    @p4
    ```
    **Affichage**
    ```sql
    PLAN_TABLE_OUTPUT
    ----------------------------------------------------------------------------------------------------
    Plan hash value: 4247486214

    ----------------------------------------------------------------------
    | Id  | Operation	  | Name	| Rows	| Bytes | Cost (%CPU)|
    ----------------------------------------------------------------------
    |   0 | SELECT STATEMENT  |		|   112K|  2083K| 70893   (1)|
    |*  1 |  TABLE ACCESS FULL| BIGANNUAIRE |   112K|  2083K| 70893   (1)|
    ----------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

    1 - filter("A"."CP">=50000 AND "A"."CP"<=9999999)

    Column Projection Information (identified by operation id):
    -----------------------------------------------------------

    1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
    ```