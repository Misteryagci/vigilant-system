# Exercice 5 : Autres requêtes

Dans cet exercice on vous demande d'expliquer “par vous même” un plan contentant un opérateur qui n'a pas été détaillé en cours.

## Question a) Requêtes avec `group by`

```sql
EXPLAIN plan FOR
    SELECT age, COUNT(*)
    FROM BigAnnuaire a
    GROUP BY age;
@p3
```

### L'explication de la requête de la question a)

L'exécution de cette requête donne l'affichage suivante

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 304907461

--------------------------------------------------
| Id  | Operation	      | Name	 | Rows  |
--------------------------------------------------
|   0 | SELECT STATEMENT      | 	 |   100 |
|   1 |  HASH GROUP BY	      | 	 |   100 |
|   2 |   INDEX FAST FULL SCAN| INDEXAGE |   220K|
--------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "AGE"[NUMBER,22], COUNT(*)[22]
   2 - "AGE"[NUMBER,22]
```

D'après le documentation Oracle;

- l'opération `HASH GROUP BY` *groupe les résultats suivant une table de hachage. Cette opération a besoin de grandes quantités de mémoire pour matérialiser le résultat intermédiaire (sans pipeline). La sortie n'est pas ordonnée de quelle que façon que ce soit.*
- ainsi l'opération `INDEX FAST FULL SCAN` *Lit l'index entier (toutes les lignes) dans l'ordre de l'index. Suivant différentes statistiques système, la base de données peut choisir de réaliser cette opération car elle a besoin de toutes les lignes dans l'ordre de l'index, par exemple à cause d'une clause order by. À la place, l'optimiseur pourrait aussi utiliser un INDEX FAST FULL SCAN et réaliser une opération de tri supplémentaire.*

Donc, l'exécution de la requête commence d'abord un parcourt de tous les lignes (donc **220 000**) de la table en les indexant par l'âge (**indexAge**). Puis groupe les résultats par index afin de pouvoir exécuter `COUNT(*)` qui permet à compter le nombre des lignes pour chaque valeur d'âge.

## Question b) Requêtes avec `group by` `having`

```sql
EXPLAIN plan FOR
    SELECT age, COUNT(*)
    FROM BigAnnuaire a
    GROUP BY age
    HAVING COUNT(*) > 200;
@p3
```

### L'explication de l'exécution de la requête de la question b)

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 3325678318

---------------------------------------------------
| Id  | Operation	       | Name	  | Rows  |
---------------------------------------------------
|   0 | SELECT STATEMENT       |	  |	5 |
|*  1 |  FILTER 	       |	  |	  |
|   2 |   HASH GROUP BY        |	  |	5 |
|   3 |    INDEX FAST FULL SCAN| INDEXAGE |   220K|
---------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(COUNT(*)>200)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "AGE"[NUMBER,22], COUNT(*)[22]
   2 - (#keys=1) "AGE"[NUMBER,22], COUNT(*)[22]
   3 - "AGE"[NUMBER,22]
```

Les opérations `HASH GROUP BY` et `INDEX FAST FULL SCAN` sont la même que la question précédente. Sauf dans cet exercice Oracle group les éléments dans le table d'hachage sous forme de 5 groupes au lieu de 100 groupes que la question précédente. C'est fait pour l'optimisation de l'exécution.

## Question c) Requête `min` `max`

```sql
EXPLAIN plan FOR
    SELECT MIN(cp), MAX(cp)
    FROM BigAnnuaire a;
@p3
```

### L'explication de l'exécution de la requête de la question c)

L'exécution de la requête en question c) donne l'affichage suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 3499556229

-------------------------------------------------
| Id  | Operation	      | Name	| Rows	|
-------------------------------------------------
|   0 | SELECT STATEMENT      | 	|     1 |
|   1 |  SORT AGGREGATE       | 	|     1 |
|   2 |   INDEX FAST FULL SCAN| INDEXCP |   220K|
-------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=0) MAX("CP")[22], MIN("CP")[22]
   2 - "CP"[NUMBER,22]
```

L'opération `INDEX FAST FULL SCAN` lit tous les lignes en utilisant l'index IndexCP qui est créé par Oracle pour les raisons d'optimisation. L'opération `SORT AGGREGATE`, d'après le documentation d'Oracle, permet juste agréger les valeurs obtenus par le parcours précédent pour détecter les valeurs minimum et maximum, et il ne trie pas les valuers même si le nom contient **SORT** qui veut dire trier en anglais.

## Question d) Requête avec `not in`

```sql
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.prenom NOT IN ( SELECT b.prenom
                        FROM BigAnnuaire b
			WHERE b.age<=7);
@p3
```

### L'explication de l'exécution de la requête de la question d)

L'exécution de la requête en question d) nous donne l'affichage suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 2010689381

------------------------------------------------------------
| Id  | Operation		     | Name	   | Rows  |
------------------------------------------------------------
|   0 | SELECT STATEMENT	     |		   |  2444 |
|*  1 |  HASH JOIN RIGHT ANTI	     |		   |  2444 |
|   2 |   TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE | 15533 |
|*  3 |    INDEX RANGE SCAN	     | INDEXAGE    | 15533 |
|   4 |   TABLE ACCESS FULL	     | BIGANNUAIRE |   220K|
------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("A"."PRENOM"="B"."PRENOM")
   3 - access("B"."AGE"<=7)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "A"."PRENOM"[VARCHAR2,30], "A"."NOM"[VARCHAR2,30]
   2 - "B"."PRENOM"[VARCHAR2,30]
   3 - "B".ROWID[ROWID,10]
   4 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
```

Dans ce plan d'exécution on a **opérations différentes** qui sont les suivantes:

1. **`HASH JOIN RIGHT ANTI`** : C'est opération vient de l'opérateur `NOT IN` qu'on avait passé dans la requête, qui signifie une anti right join. 
2. **`TABLE ACCESS BY INDEX ROWID`** : D'après la documentation d'Oracle cette opération récupère une ligne à partir de la table en utilisant le ROWID récupéré lors d'une recherche précédente dans l'index (ici c'est l'indexAge créé par *l'opération 3.*)
3. **`INDEX RANGE SCAN`** : D'après la documentation d'Oracle cette opération réalise un parcours du B-tree et suit la chaîne de nœuds feuilles pour trouver toutes les entrées correspon­dantes.
4. **`TABLE ACCESS FULL`**:  D'après le documentation d'Oracle cette opération est aussi connue sous le nom de parcours complet de table. Elle lit la table entière, toutes les lignes et toutes les colonnes, comme elle est stockée sur le disque.

Comme l'exécution de cette requête contient aussi l'exécution de la sous-requête suivante: 

```sql
SELECT b.prenom
FROM BigAnnuaire b
WHERE b.age<=7;
```
On va commencer par examiner cette requête en exécutant la requête suivante:

```sql
EXPLAIN PLAN FOR
    SELECT b.prenom
    FROM BigAnnuaire b
    WHERE b.age<=7;
@p3
```

Celle-ci nous donne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 771811286

-----------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  |
-----------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  | 15533 |
|   1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE | 15533 |
|*  2 |   INDEX RANGE SCAN	    | INDEXAGE	  | 15533 |
-----------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("B"."AGE"<=7)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "B"."PRENOM"[VARCHAR2,30]
   2 - "B".ROWID[ROWID,10]
```

Donc on peut dire que les opérations **2** et **3** de la requête principale viennent de l'exécution de cette requête. Alors on commence par l'expliquer l'exécution de cette sous-requête.
Comme détaillé précédemment l'opération `INDEX RANGE SCAN` permet de créer un index indexAge contenant les valeurs de la table BigAnnuaire dont l'attibut âge est plus petit ou égale à 7. Cet index permet de diminuer le nombre de ligne de 220 000 qui est le nombre des lignes totales de la table BigAnnuaire à 15533. C'est à cause de ça Oracle crée cet requête automatiquement.
Puis l'opération `TABLE ACCESS BT INDEX ROWID` permet de parcourir les valeurs contenu dans l'index indexAge créé précédemment ligne par ligne.

**On retourne sur l'exécution de notre requête principale;**
Comme on a expliqué les opérations 2 et 3 de cette exécution, on passe à l'opération **4** qui est `TABLE ACCESS FULL` comme détaillé précédemment, cette opération permet de parcourir tous les lignes de la table BigAnnuaire notamment 220 000 lignes.
Alors on passe à l'opération **1** qui est ̀`HASH JOIN RIGHT ANTI`. Cet opération nous indique justement qu'il y a une right anti join avec la sous-requête en se basant sur le prédicat qu'on a défini dans la clause `WHERE`, ce qui est `access("A"."PRENOM"="B"."PRENOM")`. Et cette anti join nous donne 2444 lignes résultantes.

## Question e) Requête avec `not exists`

```sql
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE NOT EXISTS ( SELECT *
                       FROM BigAnnuaire b
		       WHERE b.prenom = a.prenom
		       AND b.age < a.age);
@p3
```

### L'explication de la requête de la question e)

L'exécution de la requête de la question e) nous retourne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 1747139184

----------------------------------------------------
| Id  | Operation	     | Name	   | Rows  |
----------------------------------------------------
|   0 | SELECT STATEMENT     |		   |  4620 |
|*  1 |  HASH JOIN RIGHT ANTI|		   |  4620 |
|   2 |   TABLE ACCESS FULL  | BIGANNUAIRE |   220K|
|   3 |   TABLE ACCESS FULL  | BIGANNUAIRE |   220K|
----------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("B"."PRENOM"="A"."PRENOM")
       filter("B"."AGE"<"A"."AGE")

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "A"."PRENOM"[VARCHAR2,30], "A"."NOM"[VARCHAR2,30]
   2 - "B"."PRENOM"[VARCHAR2,30], "B"."AGE"[NUMBER,22]
   3 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30],
       "A"."AGE"[NUMBER,22]
```

La requête principale ainsi que la sous-requête consoiste à faire un parcours complet de la table BigAnnuaire, d'où les deux opérations `TABLE ACCESS FULL` sur la table BigAnnuaire (les opérations dont l'id 3 et 4).

Puis comme dans la question précédente, on fait un anti right join de ces deux tables entre le table de la requête principale est la sous-requête, en se basant sur les prédicats qu'on a définit dans la clause `WHERE` qui sont `access("B"."PRENOM"="A"."PRENOM")` et `filter("B"."AGE"<"A"."AGE")`.

## Question f) Requête avec `minus` : les code spostaux des villes qui n'ont pas de centenaire.  

```sql
EXPLAIN plan FOR
  SELECT cp
  FROM BigAnnuaire a
  minus
   SELECT cp
   FROM BigAnnuaire b
   WHERE b.age>=100;
@p3
```

### L'explication de l'exécution de la requête de la question f)

L'exécution de la requête de la question précédente donne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 3407073634

-------------------------------------------------------------
| Id  | Operation		 | Name 	    | Rows  |
-------------------------------------------------------------
|   0 | SELECT STATEMENT	 |		    |	220K|
|   1 |  MINUS			 |		    |	    |
|   2 |   SORT UNIQUE		 |		    |	220K|
|   3 |    INDEX FAST FULL SCAN  | INDEXCP	    |	220K|
|   4 |   SORT UNIQUE		 |		    |  2200 |
|*  5 |    VIEW 		 | index$_join$_002 |  2200 |
|*  6 |     HASH JOIN		 |		    |	    |
|*  7 |      INDEX RANGE SCAN	 | INDEXAGE	    |  2200 |
|   8 |      INDEX FAST FULL SCAN| INDEXCP	    |  2200 |
-------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - filter("B"."AGE">=100)
   6 - access(ROWID=ROWID)
   7 - access("B"."AGE">=100)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - STRDEF[BM VAR, 22]
   2 - (#keys=1) "CP"[NUMBER,22]
   3 - "CP"[NUMBER,22]
   4 - (#keys=1) "CP"[NUMBER,22]
   5 - "CP"[NUMBER,22], "B"."AGE"[NUMBER,22]
   6 - (#keys=1) "B"."AGE"[NUMBER,22], "CP"[NUMBER,22]
   7 - ROWID[ROWID,10], "B"."AGE"[NUMBER,22]
   8 - ROWID[ROWID,10], "CP"[NUMBER,22]
```

On va commencer par l'expliquer la requête dans l'opération `MINUS` ce qui est la requête suivante :

```sql
SELECT cp
   FROM BigAnnuaire b
   WHERE b.age>=100;
```

Alors pour celle-ci on va exécuter la commande suivante:

```sql
EXPLAIN plan FOR
SELECT cp
   FROM BigAnnuaire b
   WHERE b.age>=100;
@p3
```

Cette exécution nous retourne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4091979001

-----------------------------------------------------------
| Id  | Operation	       | Name		  | Rows  |
-----------------------------------------------------------
|   0 | SELECT STATEMENT       |		  |  2200 |
|*  1 |  VIEW		       | index$_join$_001 |  2200 |
|*  2 |   HASH JOIN	       |		  |	  |
|*  3 |    INDEX RANGE SCAN    | INDEXAGE	  |  2200 |
|   4 |    INDEX FAST FULL SCAN| INDEXCP	  |  2200 |
-----------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("B"."AGE">=100)
   2 - access(ROWID=ROWID)
   3 - access("B"."AGE">=100)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "CP"[NUMBER,22], "B"."AGE"[NUMBER,22]
   2 - (#keys=1) "B"."AGE"[NUMBER,22], "CP"[NUMBER,22]
   3 - ROWID[ROWID,10], "B"."AGE"[NUMBER,22]
   4 - ROWID[ROWID,10], "CP"[NUMBER,22]
```

Cette exécution contient 4 opérations qui sont les suivantes: 

1. `VIEW` : Cette opération crée une nouvelle vue à partir de la table BigAnnuaire on se basant sur le prédicat filter qu'on définit dans la clause `WHERE` de la requête. Ce prédicat est `filter("B"."AGE">=100)` donc on peut dire que cette opération permet de créer une table virtuelle à partir de la table actuelle mais uniquement avec les éléments dont leur attribut âge est plus grand ou égale à 100. Oracle crée une table virtuelle au lieu d'exécuter les opérations sur la table courante pour des raisons de performance. Parce que comme dans le clause `SELECT` on a l'attibut `cp` et dans la clause `WHERE` on a l'attribut `age` on devait manipuler deux index sur 220 000 lignes, ce qui va poser des problème de performance.
2. `HASH JOIN`: Cette opération crée une table d'hachage contenant les résultats obtenus par les deux opérations intérieurs qui sont les suivantes `INDEX RANGE SCAN` et `INDEX FAST FULL SCAN`. Cette opération est exécuté sur la table virtuelle crée par Oracle.
3. `INDEX RANGE SCAN`; Cette opération d'après la documentation d'Oracle, fait un parcours de B-Tree en se basant sur le prédicat `access("B"."AGE">=100)` qu'on a passé dans la clause `WHERE`
4. `INDEX FAST FULL SCAN`: D'après la documentation d'Oracle cette opération lit l'index en entier (toutes les lignes) comme stocké sur disque. Cette opération est typiquement exécutée à la place d'un parcours complet de table si toutes les colonnes requises sont disponibles dans l'index. Comme le TABLE ACCESS FULL, l'opération INDEX FAST FULL SCAN peut bénéficier d'opérations de lecture multi-blocs. Alors dans notre exemple cet opération lit tous les valeurs contenus dans l'index indexCp créé par Oracle de manière automatique pour les raisons d'optimisation.

Une fois qu'on a examiné l'exécution de la sous-requête, on revient sur l'exécution de la requête principale. Comme on peut observer les opérations **5**.**6**.**7**.**8** viennent de l'exécution de sous-requête. Alors il nous reste à examiner que les opérations **1**,**2**,**3** et **4**. Ces opérations sont les suivantes:

1. `MINUS` : Cette opération signifie la même chose que l'opération `MINUS`(MySQL et Oracle) ou `EXCEPT` (PostgreSQL). Ce qui permet de retourner les valeus appartenant à la table T1 mais pas à la table T2 (on considère la requête `T1 MINUS T2` où le T1 et T2 sont deux tables). Donc dans notre exemple ça signifie les attributs cp des éléments qui appartient à la table BigAnnuaire dont l'attribut age est strictement plus petit que 100.
2. `SORT UNIQUE` : Cette opération retourne une liste triées des valeurs différentes d'une liste. Dans notre cas elle retourne la liste triée des valeurs distinctes de `indexCP`  
3. `INDEX FAST FULL SCAN` : Comme précédemment cette opération permet de parcourir tous les valeurs de l'index. Dans notre cas l'index est `indexCP`.
4. `SORT UNIQUE`: Idem que l'opération **2.** mais cette fois ci elle retourne une liste triée des éléments distinctes de la table virtuelle en exécutant la sub-query qu'on a détaillé précédemment. 

**Remarque :** Les opérations `SORT UNIQUE` viennent de l'opération `MINUS` pour des raisons de performance Oracle trie et enlève les doublons sur les deux listes qu'il va exécuter l'opération ̀`MINUS`.

## Question g) requête avec `where age >= ALL (…)`

```sql
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.age >= ALL (SELECT b.age 
                       FROM BigAnnuaire b
		       WHERE b.cp = 75000);
@p3
```

### L'explication de l'exécution de la requête de la question g)

L'exécution de la requête de la question g) nous retourne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 19589426

-------------------------------------------------------------
| Id  | Operation		      | Name	    | Rows  |
-------------------------------------------------------------
|   0 | SELECT STATEMENT	      | 	    |  2200 |
|   1 |  MERGE JOIN ANTI	      | 	    |  2200 |
|   2 |   SORT JOIN		      | 	    |	220K|
|   3 |    TABLE ACCESS FULL	      | BIGANNUAIRE |	220K|
|*  4 |   SORT UNIQUE		      | 	    |	220 |
|   5 |    TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE |	220 |
|*  6 |     INDEX RANGE SCAN	      | INDEXCP     |	220 |
-------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("A"."AGE"<"B"."AGE")
       filter("A"."AGE"<"B"."AGE")
   6 - access("B"."CP"=75000)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=0) "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
   2 - (#keys=1) "A"."AGE"[NUMBER,22], "A"."NOM"[VARCHAR2,30],
       "A"."PRENOM"[VARCHAR2,30]
   3 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30],
       "A"."AGE"[NUMBER,22]
   4 - (#keys=1) "B"."AGE"[NUMBER,22]
   5 - "B"."AGE"[NUMBER,22]
   6 - "B".ROWID[ROWID,10]
```

On commence par examiner la sous requête à l'intérieur de l'opération `ALL`qui est le suivante :

```sql
SELECT b.age 
FROM BigAnnuaire b
WHERE b.cp = 75000;
```

Pour examiner cette requête on exécute la requête suivante: 
```sql
EXPLAIN plan FOR
    SELECT b.age 
    FROM BigAnnuaire b
    WHERE b.cp = 75000;
@p3
```

L'exécution de cette dernière retourne l'affichage suivante:
```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 1858303794

-----------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  |
-----------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  |   220 |
|   1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE |   220 |
|*  2 |   INDEX RANGE SCAN	    | INDEXCP	  |   220 |
-----------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("B"."CP"=75000)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "B"."AGE"[NUMBER,22]
   2 - "B".ROWID[ROWID,10]
```

L'examiner l'exécution de cette requête revient à examiner les deux opérations suivantes:

1. **`TABLE ACCESS BY INDEX ROWID`** : Comme définit précedemment, cette opération consiste à parcourir par le nombre des lignes une liste obtenue précédemment par un index. Dans notre cas c'est l'index `indexCP`. 
2. **`INDEX RANGE SCAN`** : Comme définit précédemment, cette opération consiste à parcourir le B-Tree par les prédicats qui détermine le début et/ou la fin du parcours. Dans notre cas c'est le prédicat d'access `access("B"."CP"=75000)`. Donc plus clairement, cette opération crée un index indexCP sur les éléments de la table BigAnnuaire dont l'attribut cp est 75000.

Comme on a finit d'examiner l'exécution de la sous-requête, on revient sur l'exécution de la requête principale.
Comme on peut remarquer, les opérations **4** et **5** de l'exécution principale sont identiques aux opérations de cette sous-requête. Il nous reste donc a examiner les opérations suivantes: 

1. **`MERGE JOIN ANTI`** : Cette opération permet de faire simplement une jointure des deux opérations de scan. Dans notre cas cette opération permet de faire une jointure des résultats obtenues par les opérations **2** et **4**.
2. **`SORT JOIN`** : Comme son nom indique cette opération consiste à lire les deux tables (via un opération `FULL TABLE SCAN`) et trie les lignes lues. Dans notre cas ces deux tables sont la table **BigAnnuaire** lu par *l'opération 3.* et la table trié obtenue par *l'opération 4*. Donc on fait une jointure de ces deux tables aussi en les triant.
3. **`TABLE ACCESS FULL`** : Cette opération permet de parcourir tous les valeurs contenues dans la table, autrement dit il fait un parcours complet de la table. Dans notre cas la table est la table BigAnnuaire.
4. **`SORT UNIQUE`**: Cette opération permet de trier les valeurs distinctes contenus dans une liste. Dans notre cas cette liste est le résultat de la sous-requête qu'on a examiné précédemment. Pour cette opération de trie et filtrage des doublons fait avec les prédicats suivantes:  `access("A"."AGE"<"B"."AGE")` `filter("A"."AGE"<"B"."AGE")`

## Question h) Requête avec UNION, avec UNION ALL, avec une division, …

On va examiner différentes requêtes sous 6 sous-catégories d'après la documentation d'Oracle. D'après le documentation d'Oracle les opérateurs de SQL peut être classés sous forme de 6 catégories, qui sont les suivantes

### Question h.1) Requêtes avec des opérateurs arithmétiques

Dans ce catégorie on a 6 différentes opérateurs qui sont les suivantes

#### 1. Requête avec l'opérateur `+` (unaire)

La documentation d'Oracle indique que cette opérateur permet de rendre l'opérande positif. Alors pour voir le plan d'exécution de cet opérateur sur notre table on lance la requête suivante:

```sql
EXPLAIN plan FOR
SELECT +a.age 
FROM BigAnnuaire a;
@p3
```

L'exécution de la requête retourne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4203953806

-------------------------------------------------
| Id  | Operation	     | Name	| Rows	|
-------------------------------------------------
|   0 | SELECT STATEMENT     |		|   220K|
|   1 |  INDEX FAST FULL SCAN| INDEXAGE |   220K|
-------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."AGE"[NUMBER,22]
```

Dans cette exécution on a qu'une seule opération ce qui est **`INDEX FAST FULL SCAN`**. Comme expliqué précédemment cette opération lit l'index en entier (tous les lignes) comme stocké sur le disque. Cette opération est typiquement exécutée à la place d'un parcours complet de table si toutes les colonnes requises sont disponible dans l'index. Dans notre cas l'index qu'elle a lu est l'index `indexAge` que l'Oracle a créé automatiquement pour des raisons d'optimisation.

#### 2. Requête avec l'opérateur `-` (unaire)

La documentation d'Oracle indique que cette opération permet de rendre l'opérande négatif. Alors pour voir le plan d'exécution de cet opérateur sur notre table on lance la requête suivante:

```sql
EXPLAIN plan FOR
SELECT -a.age
FROM BigAnnuaire a;
@p3
```

L'exécution de cette requête donne l'affichage suivante:

```sql

PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4203953806

-------------------------------------------------
| Id  | Operation	     | Name	| Rows	|
-------------------------------------------------
|   0 | SELECT STATEMENT     |		|   220K|
|   1 |  INDEX FAST FULL SCAN| INDEXAGE |   220K|
-------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."AGE"[NUMBER,22]
```

Comme la requête de la question précédente, dans cette affichage on a qu'une seule opération qui est **`INDEX FAST FULL SCAN`** qui permet de lire tous l'index `IndexAge`.

#### 3. Requête avec l'opérateur `/` (sur les dates et les nombres)

La documentation d'Oracle indique que cette opération permet de faire une division entre les deux entiers. Alors pour voir le plan d'exécution de cet opérateur sur notre table on lance la requête suivante:

```sql
EXPLAIN plan FOR
SELECT a.age/100
FROM BigAnnuaire a;
@p3
```

L'exécution de cette requête nous retourne l'affichage suivant:

```sql

PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4203953806

-------------------------------------------------
| Id  | Operation	     | Name	| Rows	|
-------------------------------------------------
|   0 | SELECT STATEMENT     |		|   220K|
|   1 |  INDEX FAST FULL SCAN| INDEXAGE |   220K|
-------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."AGE"[NUMBER,22]
```

Comme dans les deux question précédentes, on a qu'une seule opération qui est `INDEX FAST FULL SCAN` qui nous permet de parcourir tout l'index `IndexAge`.

#### 4. Requête avec l'opérateur `*`

D'après le documentation d'Oracle cette opération permet de réaliser une opération de multiplication. Pour pouvoir examiner le plan d'exécution de cet opérateur on lance la requête suivante:

```sql
EXPLAIN plan FOR
SELECT a.age * 100
FROM BigAnnuaire a;
@p3
```

Cette exécution nous affiche le suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4203953806

-------------------------------------------------
| Id  | Operation	     | Name	| Rows	|
-------------------------------------------------
|   0 | SELECT STATEMENT     |		|   220K|
|   1 |  INDEX FAST FULL SCAN| INDEXAGE |   220K|
-------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."AGE"[NUMBER,22]
```

Comme les dernières exécutions cette exécution aussi une seule opération qui est `INDEX FAST FULL SCAN` qui permet de lire tous les données contenus dans l'index `indexAge`.

#### 5. Requête avec l'opérateur `+`

D'après la documentation d'Oracle cette opération permet de réaliser une opération d'addition entre deux nombres ou dates. Pour pouvoir examiner le plan d'exécution de cette requête on exécute la requête suivante:

```sql
EXPLAIN plan FOR
SELECT a.age + a.cp
FROM BigAnnuaire a;
@p3
```

Cette exécution nous donne l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4212934415

-----------------------------------------------------------
| Id  | Operation	       | Name		  | Rows  |
-----------------------------------------------------------
|   0 | SELECT STATEMENT       |		  |   220K|
|   1 |  VIEW		       | index$_join$_001 |   220K|
|*  2 |   HASH JOIN	       |		  |	  |
|   3 |    INDEX FAST FULL SCAN| INDEXAGE	  |   220K|
|   4 |    INDEX FAST FULL SCAN| INDEXCP	  |   220K|
-----------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access(ROWID=ROWID)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."CP"[NUMBER,22], "A"."AGE"[NUMBER,22]
   2 - (#keys=1) "A"."AGE"[NUMBER,22], "A"."CP"[NUMBER,22]
   3 - ROWID[ROWID,10], "A"."AGE"[NUMBER,22]
   4 - ROWID[ROWID,10], "A"."CP"[NUMBER,22]
```

Cette exécution contient 4 opérations qui sont les suivantes:

1. `VIEW` : D'après la documentation d'Oracle cette opération permet de créer une table virtuelle.
2. `HASH JOIN` : D'après la documentation d'Oracle la jointure de hachage charge les enregistrements candidats d'un côté de la jointure dans une table de hachage qui est ensuite sondée pour chaque ligne de l'autre côté de la jointure.
3. `INDEX FAST FULL SCAN` : Cette opération permet de parcourir toutes les valeurs de l'index `indexAge`.
4. `INDEX FAST FULL SCAN` : Cette opération permet de parcourir toutes les valeurs de l'index `IndexCP`.

Comme dans la clause `SELECT` de notre requête, on parcourt d'abord les deux index `indexCP` et `indexAge`. Puis on crée une table de hachage en utilisant les valeurs de ces deux indexes qui sont sur la même ligne. Et puis, on crée une table virtuelle en partant de cette table d'hachage pour en suite sélectionner les valeurs qu'on cherche.

#### 6. Requête avec l'opérateur `-`

D'après la documentation d'Oracle cet opérateur permet de faire une soustraction entre deux nombres ou dates. Pour pouvoir examiner le plan d'exécution de cet opérateur on exécute la requête suivante:

```sql
EXPLAIN plan FOR
SELECT a.age - a.cp
FROM BigAnnuaire a;
@p3
```

L'exécution de cette requête nous rends l'affichage suivante:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4212934415

-----------------------------------------------------------
| Id  | Operation	       | Name		  | Rows  |
-----------------------------------------------------------
|   0 | SELECT STATEMENT       |		  |   220K|
|   1 |  VIEW		       | index$_join$_001 |   220K|
|*  2 |   HASH JOIN	       |		  |	  |
|   3 |    INDEX FAST FULL SCAN| INDEXAGE	  |   220K|
|   4 |    INDEX FAST FULL SCAN| INDEXCP	  |   220K|
-----------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access(ROWID=ROWID)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."CP"[NUMBER,22], "A"."AGE"[NUMBER,22]
   2 - (#keys=1) "A"."AGE"[NUMBER,22], "A"."CP"[NUMBER,22]
   3 - ROWID[ROWID,10], "A"."AGE"[NUMBER,22]
   4 - ROWID[ROWID,10], "A"."CP"[NUMBER,22]
```
Comme on peut remarquer, le plan d'exécution de la requête avec l'opérateur `-` est identique avec celui avec l'opérateur `+`. On parcourt tous les valeurs dans les deux index et on les met dans une table d'hachage en suite en crée une nouvelle table virtuelle.

**Remarque :**  Exécution des opérateurs arithmétiques consistent seulement de faire un simple parcourt complet de tous les valeurs de l'index si seulement un seul opérande est une colonne de la table. Et dans les cas si les deux opérandes de l'opération sont des colonnes de la table, l'exécution consiste à faire un parcours de chacun des index et de faire une jointure sur ces deux index et aussi de créer une nouvelle table virtuelle à partir de cette jointure.

### Question h.2) Requêtes avec des opérateurs sur les caractères

#### 1. Opérateur `||`

D'après la documentation d'Oracle cette opérateur permet de concaténer deux chaînes de caractères. Pour pouvoir examiner le plan d'exécution de cet opérateur on exécute la requête suivante:

```sql
EXPLAIN plan FOR 
SELECT prenom||' '||nom
FROM BigAnnuaire;
@p3
```

L'exécution de cette requête nous donne l'affichage suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4247486214

-------------------------------------------------
| Id  | Operation	  | Name	| Rows	|
-------------------------------------------------
|   0 | SELECT STATEMENT  |		|   220K|
|   1 |  TABLE ACCESS FULL| BIGANNUAIRE |   220K|
-------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "NOM"[VARCHAR2,30], "PRENOM"[VARCHAR2,30]
```

Dans ce plan  d'exécution on a qu'une seule opération ce qui est `TABLE ACCESS FULL`. D'après la documentation d'Oracle cette opération est aussi connue sous le nom de parcours complet de table. Elle lit la table entière, toutes les lignes et toutes les colonnes, comme elle est stockée sur le disque. Donc dans notre exemple, on parcourt tout les lignes et les colonnes de la table pour récupérer les valeurs `NOM` et `PRENOM` qu'on va ensuite concaténer dans la clause `SELECT`.

### Question h.3) Requêtes avec des opérateurs de comparaison

#### 1. Opérateur `=`

D'après la documentation d'Oracle cette opérateur permet de faire une teste d'égalité. Pour pouvoir examiner le plan d'exécution de cet opérateur on exécuté la requête suivante:

```sql
EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age = 20;
@p3
```

L'exécution de cette requête nous donne l'affichage suivant:

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

   2 - access("A"."AGE"=20)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30],
       "A"."AGE"[NUMBER,22], "A"."CP"[NUMBER,22], "A"."TEL"[VARCHAR2,10],
       "A"."PROFIL"[VARCHAR2,4000]
   2 - "A".ROWID[ROWID,10], "A"."AGE"[NUMBER,22]
```

Sur ce plan d'exécution on a 2 opérations qui sont:

1. `TABLE ACCESS BY INDEX ROWID` : Cette opération récupère une ligne à partir de la table en utilisant ROWID récupéré lors d'une recherche précédente dans l'index.
2. `INDEX RANGE SCAN` : Cette opération permet de faire un parcours de B-Tree et suit la chaîne des noeuds feuilles pour trouver toutles les entrées correspondantes. Pour cela on utilise un index. Dans notre cas c'est l'index `indexAge`. Le début et la fin de ce parcours de B-Tree sont déterminés par les prédicats. Dans notre exemple on a qu'un seul prédicat de type **ACCESS** qui nous permet de limiter le parcours avec les valeurs de la table dont l'attribut age est égale à 20.

**Conclusion :** Donc on peut dire que l'opérateur `=` qui permet de tester l'égalité nous crée un index sur l'attribut qu'on teste son égalité (Pour les raisons d'optimisation de Oracle). Ainsi, ça nous crée un prédicat de type **ACCESS** qui permet de parcourir que les valeurs dont on teste l'égalité sur l'index créé précédemment.

#### 2. Opérateur de teste d'inégalité `!=` || `^=` || `<>` || `¬=`

Ces opérateurs permettent de tester l'inégalité entre deux valeurs. Pour pouvoir examiner le plan d'exécution de cet opérateur d'inégalité on exécute la requête suivante

```sql
EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age <> 20;
@p3
```

L'exécution de cette requête nous rend l'affichage suivant :

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4247486214

-------------------------------------------------
| Id  | Operation	  | Name	| Rows	|
-------------------------------------------------
|   0 | SELECT STATEMENT  |		|   217K|
|*  1 |  TABLE ACCESS FULL| BIGANNUAIRE |   217K|
-------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("A"."AGE"<>20)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30],
       "A"."AGE"[NUMBER,22], "A"."CP"[NUMBER,22], "A"."TEL"[VARCHAR2,10],
       "A"."PROFIL"[VARCHAR2,4000]
```

Comme on peut observer ici on a qu'une seule opération qui est `TABLE ACCESS FULL` qui est connue sous le nom de parcours complet de table. Elle lit la table entière, toutes les lignes et toutes les colonnes, comme elle est stockée sur le disque. On a aussi un prédicat de type **FILTER** qui permet de filtrer les éléments par rapport à sa condition.
Dans notre cas, on fait un parcours complet de la table et avec le prédicat filter, on affiche que les valeurs dont l'attribut age est différent de 20.

#### 2. Opérateurs `>` et `<`
Ces deux opérateurs permettent de faire des tests **plus grand que** et **plus petit que**.
Pour pouvoir examiner le plan d'exécution de ces deux opérateur on exécuté les requêtes suivantes:

- Requête 1 : **plus grand que**

```sql
    EXPLAIN plan FOR
    SELECT *
    FROM BigAnnuaire a
    WHERE a.age > 20;
    @p3
```

- Requête 2 :**plus petit que**

```sql
    EXPLAIN plan FOR
    SELECT *
    FROM BigAnnuaire a
    WHERE a.age < 20;
    @p3
```

L'exécution de ces deux requêtes nous donne les affichages suivants:

- Affichage de la requête 1

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4247486214

-------------------------------------------------
| Id  | Operation	  | Name	| Rows	|
-------------------------------------------------
|   0 | SELECT STATEMENT  |		|   177K|
|*  1 |  TABLE ACCESS FULL| BIGANNUAIRE |   177K|
-------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("A"."AGE">20)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30],
       "A"."AGE"[NUMBER,22], "A"."CP"[NUMBER,22], "A"."TEL"[VARCHAR2,10],
       "A"."PROFIL"[VARCHAR2,4000]
```

- Affichage de la requête 2

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 771811286

-----------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  |
-----------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  | 42222 |
|   1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE | 42222 |
|*  2 |   INDEX RANGE SCAN	    | INDEXAGE	  | 42222 |
-----------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("A"."AGE"<20)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30],
       "A"."AGE"[NUMBER,22], "A"."CP"[NUMBER,22], "A"."TEL"[VARCHAR2,10],
       "A"."PROFIL"[VARCHAR2,4000]
   2 - "A".ROWID[ROWID,10], "A"."AGE"[NUMBER,22]
```


Comme on peut voir dans ces deux exécutions Oracle a utilsé un index pour l'exécution de la requête 2 et utiliser un prédicat de type filter sur le parcours complet de la table dans l'exécution de la requête 1. Ce choix est fait par Oracle pour les raisons d'optimisations. Autrement dit, Oracle a préféré de créer un index pour la requête dont le nombre de lignes retournés n'est pas très grand et d'utiliser un prédicat de type filter pour la requête dont le nombre de lignes retournés est très grand *(Le nombre des lignes retournés par la requête 2 est 42222 et le nombre des lignes retournés par la requête 1 est 172 000)*

#### 3. Opérateurs `>=` et `<=`

Ces opérateurs permettent de faire des tests **plus petit ou égal** et **plus grand ou égal**. Pour pouvoir examiner le plan d'exécution de ces deux opérateurs on exécute les deux commandes suivantes:

- Requête 1 `>=`

```sql
EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age >= 20;
@p3
```

- Requête 2 `<=`

```sql
EXPLAIN plan FOR
SELECT *
FROM BigAnnuaire a
WHERE a.age <= 20;
@p3
```

L'exécution de ces deux requêtes rendent ces deux affichages suivants:

- L'afficahage de la requête 1

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 4247486214

-------------------------------------------------
| Id  | Operation	  | Name	| Rows	|
-------------------------------------------------
|   0 | SELECT STATEMENT  |		|   179K|
|*  1 |  TABLE ACCESS FULL| BIGANNUAIRE |   179K|
-------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("A"."AGE">=20)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30],
       "A"."AGE"[NUMBER,22], "A"."CP"[NUMBER,22], "A"."TEL"[VARCHAR2,10],
       "A"."PROFIL"[VARCHAR2,4000]
```

- L'affichage de la requête 2

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 771811286

-----------------------------------------------------------
| Id  | Operation		    | Name	  | Rows  |
-----------------------------------------------------------
|   0 | SELECT STATEMENT	    |		  | 44422 |
|   1 |  TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE | 44422 |
|*  2 |   INDEX RANGE SCAN	    | INDEXAGE	  | 44422 |
-----------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("A"."AGE"<=20)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30],
       "A"."AGE"[NUMBER,22], "A"."CP"[NUMBER,22], "A"."TEL"[VARCHAR2,10],
       "A"."PROFIL"[VARCHAR2,4000]
```

Ces deux exécutions sont pareil que les deux exécutions de la question précédente. On peut utiliser le même raisonnement pour l'explication.

#### 4. Opérateur `IN`

Cette opérateur permet de tester si la valeur est égale à au moins une des éléments de la liste. Pour tester l'exécution de cette requête on exécute la requête suivante:

```sql
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.prenom IN ( SELECT b.prenom
                        FROM BigAnnuaire b
			            WHERE b.age<=7);
@p3
```

L'exécution de cette requête nous donne l'affichage suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 336862446

------------------------------------------------------------
| Id  | Operation		     | Name	   | Rows  |
------------------------------------------------------------
|   0 | SELECT STATEMENT	     |		   |   220K|
|*  1 |  HASH JOIN RIGHT SEMI	     |		   |   220K|
|   2 |   TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE | 15533 |
|*  3 |    INDEX RANGE SCAN	     | INDEXAGE    | 15533 |
|   4 |   TABLE ACCESS FULL	     | BIGANNUAIRE |   220K|
------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("A"."PRENOM"="B"."PRENOM")
   3 - access("B"."AGE"<=7)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "A"."PRENOM"[VARCHAR2,30], "A"."NOM"[VARCHAR2,30]
   2 - "B"."PRENOM"[VARCHAR2,30]
   3 - "B".ROWID[ROWID,10]
   4 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
```

Comme on peut voir sur le plan d'exécution on peut observer qu'il y a 4 opérations qui sont les suivantes:

1. `HASH JOIN RIGHT SEMI`: Cette opération nous permet de réaliser une semi jointure de droite, en utilisant les valeurs obtenu par l'opération 2. et les valeurs obtenues par l'opération 4.
2. `TABLE ACCESS BY INDEX ROWID`: Permet de parcourir toutes les valeurs stockées dans l'index précédente par le ROWID.
3. `INDEX RANGE SCAN` : Permet de faire un parcours de B-Tree en déterminant les conditions d'entrée et sor
4. `TABLE ACCESS FULL` ; Permet de parcourir toutes les lignes et colonne de la table

Alors l'exécution de notre requête consiste à faire un parcours de B-Tree en se limitant sur les valeurs dont l'attribut age est plut petit ou égal à 7 vient de l'exécution de la requête à l'intérieur de l'opérateur `IN` qui est 
```sql
SELECT b.prenom
 FROM BigAnnuaire b
```

Et puis un parcours complet de la table BigAnnuaire, pour récupérer les attribut prenom et nom.

Une fois que ces deux opérations sont fait, de faire une semi jointure par la droite en se basant sur la condition que les attributs prenom de ces deux valeurs doivent être égaux.

#### 5. Opérateur ` NOT IN`

On avait examiné l'exécution de cette opérateur dans une question précédente ([voir la question d)](#question-d-requête-avec-not-in)).

