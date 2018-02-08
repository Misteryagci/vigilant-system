 # [TME Index](http://www-bd.lip6.fr/wiki/site/enseignement/master/bdr/tmeindex)


L'objectif de ce TME est de comprendre l'utilisation des index pour évaluer des sélections: création d'un index, choix d'un ou plusieurs index pour évaluer une requête, avantages/inconvénients d'un index. Ce TME dure 2 séances:

- Séance 1 : Exercice 1,2,3
- Séance 2 : Exercice 4 et suivants

## Préparation du TME

| Commande      | Description  |
| :------------:|:------------:|
| `cd mon_répertoire` | aller dans votre répertoire de travail |
| `tar zxvf /Infos/bd/public/tmeIndex.tgz` | installer l'archive dans votre répertoire principal |
| `cd tmeIndex` | aller dans le répertoire du TME |
| `emacs tmeIndex.sql &` | éditer le fichier à compléter pendant le TME |
| **Alt-x** `my/sql-oracle` ou **Atl-x** `sql-oracle` | [se connecter à Oracle.](http://www-bd.lip6.fr/wiki/site/enseignement/documentation/oracle/connexionoracle) |
| aller sur la ligne contenant @annuaire et faire Ctrl-C Ctrl-C | définir la table Annuaire et un synonyme pour la table BigAnnuaire |

Dans ce TME on interroge les deux tables Annuaire et BigAnnuaire.

| Table         | Nombre de tuplets  | Taille (moyenne) d'un tuple |
|:-------------:|:------------------:|:------------------:|
|Annuaire|2000|3846|
|BigAnnuaire|2Z0 000|3846|

Les schémas des deux tables sont identiques et contiennent les attributs suivants:

| Attribut | Valeurs distinctes | Domaine | Type | Index |
|:--------:|:------------------:|:-------:|:----:|:-----:|
| âge | 100 | [1-100] | NUMBER(3) | IndexAge |
| cp | 1000 | [1000,100900] multiples de &00 | NUMBER(3) | IndexCP |
| nom | 100 | - | VARCHAR2(30) | - |
| prénom | 90 | - | VARCHAR2(30) | - |
| tel | 100 000 pour BigAnnuaire | - | VARCHAR2(10) | - |
| profil | 90 000 pour BigAnnuaire | - | VARCHAR2(4000) | - |

Les deux tables sont indexées : **IndexAge** sur l'attribut age et **IndexCP** sur l'attribut cp.

On étudie des requêtes de sélection sur 1 ou 2 attributs. Il y a trois types de prédicats de sélection : l'égalité, l'inégalité et l'inclusion dans un intervalle.

Le SGBD transforme une requête en un plan avant de l'évaluer. Pour **afficher** le plan d'une requête, commencer chaque requête par

```sql
explain plan for SELECT ... 
```

puis terminer chaque requête par 

```sql
@p3
```

**Remarque 1 :**  pour régler l'affichage plus ou moins détaillé d'un plan, remplacer `@p3` par le niveau de détail souhaité allant de 1 à 5 : de `@p1` (plan peu détaillé) jusqu'à @p4 (plan avec son coût) ou `@p5` (plan avec tous les détails).

**Remarque2 :** **Problème d'affichage trop long**. si par erreur vous avez lancé l'exécution d'une requête en oubliant l'entête explain plan for vous pourriez être gêné par l'affichage de plusieurs milliers de nuplets. Vous pouvez stopper la requête : cliquer dans la fenêtre nommée *SQL* puis cliquer sur le menu Signals→BREAK
 
## [Exercice préliminaire. Statistiques sur les tables](Exercice0.md)

## Exercice 1: Requête de sélection utilisant un index

 Expliquer le plan des requêtes suivantes. Détailler chaque étape de l'évaluation d'un plan. 

### Question a)

```sql
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.age = 18;
@p3
```
**Explication**

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
- Le dernier opération est le **INDEX RANGE SCAN**. Cet opération réalise un parcours du B-tree et suit la chaîne de nœuds feuilles pour trouver toutes les entrées correspon­dantes. Le débutet le fin de cet opération est déterminé par le **prédicat d'access** qui est indiqué dans la section **Predicate Information** de l'affichage ci-dessus. Ce prédicat nous indique que le parcours de l'arbre est fait uniquement dans le cas de l'attribut âge est 18.

### Question b)
 
```sql
EXPLAIN plan FOR
    SELECT a.nom, a.prenom
    FROM BigAnnuaire a
    WHERE a.age BETWEEN 20 AND 29;
@p3
```
**Explication**

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
 
### Question c)

```sql
explain plan for
   select a.nom, a.prenom
   from BigAnnuaire a
   where a.age < 70 and (a.cp = 93000 or a.cp = 75000);
@p3
```
**Explication**

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
4. **INDEX RANGE SCAN** qui le même rôle que précédemment donc réalise un parcours du B-Tree et suit la chaîne de noeuds feuilles pour trouver toutes les entrées correspondantes. Ce dernier est contrôlé par un prédicat qui est détaillé dans la section **Predicate Information** de l'affichage précédent. Dans cet exemple on a deux prédicats différents. Notamment un **prédicat d'accès** et un **prédicat filter**. Le prédicat d'accès nous permet d'exprimer les condition pour le début et la fin du parcours de B-Tree et le prédicat filter, ici ne fait pas partie de l'index mais qui est sur une autre colonne de la table, qui permet de filtrer les données par rapport à son condition. Mais comme icin il ne fait pas partie de l'index mais une autre colonne de la table, la base des données doivent charger la ligne à partir de la table pour pouvoir ensuite appliquer le filre au niveau de l'opération **TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE**

### Question d)

```sql
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age = 20 and a.cp = 13000 and a.nom like 'T%';
@p3
```

**Explication**

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

1. **SELECT STATEMENT** une déclaration de SELECT qui permet d'identifier la nature du reqûete.
2. **TABLE ACCES BY INDEX ROWID** une opération comme les précédentes, qui permet d'accéder aux lignes de la table en utilisant l'index qui est crée par une recherche précédente.
3. **BITMAP CONVERSION TO ROWIDS** permet de convertir les valeurs en BITMAP aux valeurs de type ROWID pour pouvoir l'accéder aux lignes.
4. **BITMAP AND** permet d'avoir un seul BITMAP en cumulant deux BITMAPs.
5. **BITMAP CONVERSION FROM ROWIDS** permet de convertir une valeur de type ROWIDS à une valeur de type BITMAP
6. **INDEX RANGE SCAN** réalise un parcours du B-Tree et suit la chaîne de noeuds feuilles pour trouver toutes les entrées correspondantes. Ce dernier est contrôlé par un prédicat qui est détaillé dans la section **Predicate Information** de l'affichage précédent.
7. **BITMAP CONVERSION FROM ROWIDS** permet de convertir une valeur de type ROWIDS à une valeur de type BITMAP
8. **INDEX RANGE SCAN** réalise un parcours du B-Tree et suit la chaîne de noeuds feuilles pour trouver toutes les entrées correspondantes. Ce dernier est contrôlé par un prédicat qui est détaillé dans la section **Predicate Information** de l'affichage précédent.

**REMARQUE :** Quand il y a plus de 1 prédicat d'accès, on doit trouver une solution pour créer un index en commun en suivant ces deux prédicats. Comme cet index ne peut pas être obtenu en cumulant simplement les index de type ROWID, Oracle  les convertit en BITMAP juste après l'exécution de l'operation, les cumule en tant que BITMAP pour avoir un index commun pour tous les prédicats d'accès et puis refait un tranformation de type BITMAP au type ROWID pour avoir un index.

Les prédicats liés a ce requête sont :

- Il y a **deux prédicats d'accès** qui permettant de côntroler le début et le fin du parcours de B-Tree. L'un des deux prédicats détermine que le parcours sera fait uniquement  dans la condition que l'attribut CP est égale à 13000 et l'autre prédicat d'accès détermine que le parcours sera fait uniquement dans la condition que l'attribut AGE est égal à 20. (*Le passage par BITMAP nous permet d'avoir l'index sur les lignes dont l'attibut age est égale à 20 __et__ l'attribut CP est égale à 13000*)

**REMARQUE :** Oracle utilise deux index pour l'évaluation de cette requête et transforme la conjonction SQL (AND) en une intersection des adresses n-uplets (ROWID). Cette intersection est calculée par l'opérateur BITMAP AND sur un encodage binaire des ensembles d'adresses (en BITMAP). 

## Exercice 2 : Sélection AVEC OU SANS index
Dans les plans suivants, on affiche son coût (voir la colonne Cost) 

### Question a)
Etudiez plusieurs variantes de la requête sélectionnant les personnes dont l'âge est inférieur à une valeur donnée. Pour cela, testez les prédicats de la forme age < = A avec A valant 10, 30, 40, 60 et 80. 

```sql
explain plan for
    select a.nom, a.prenom
    from BigAnnuaire a
    where a.age <= 10;
@p4
```

**Affichage**
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
**Affichage**
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
**Affichage**
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
**Affichage**
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

**Affichage**
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


### Question b)  
**Pour quel prédicat Oracle préfère-t-il évaluer la requête sans utiliser l'index IndexAge ? Pourquoi ?**

**Réponse**

Oracle évalue les requêtes `age <= 40`,`age <= 60`, `age <= 80` sans utiliser l'index IndexAge. Parce que le nombre des lignes retourné par ces prédicats sont tellement important que l'Oracle par défaut préfère de parcourir tout la table de filtrer les données en utilisant ces prédicats qu'utiliser des indexes et les manipuler. C'est un optimisation que l'Oracle fait automatiquement.

### Question c)
**Proposer deux requêtes BETWEEN 50000 AND … sélectionnant un intervalle de valeurs du code postal comprises entre 50000 et N.**
- **la première utilise l'index IndexCP,**
- **la deuxième ne l'utilise pas.**

**Réponse**
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
## Exercice 3. Comparaison de plans d'exécutions équivalents



Pour une requête donnée, on veut étudier plusieurs plans équivalents afin de comparer le coût de chacun d'entre eux. Rappel pour afficher le coût, utiliser @p4

**Directive pour forcer/empêcher l'usage d'un index**

Énumérer les plans équivalents revient à considérer toutes les combinaisons entre utiliser des index ou pas en ajoutant les directives index(Table Index) et no_index(Table Index) dans les requêtes SQL. Le 1er paramètre est le nom d'une table ou d'un alias déclaré dans la clause FROM. Le 2eme paramètre est le nom d'un index. La syntaxe est détaillée ci-dessous. 

### Question a) : Comparez deux plans équivalents pour la requête age < 7 qui est très sélective. 

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

**Réponse**
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

Par rapport a ces deux exécutions, on peut remarquer que l'utilisation d'un index optimise le coût de la requête, et dimunuant le nombre des lignes parcouru par la requête.

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

### Question b) : Idem pour la requête age > 19 qui est peu sélective. 

On exécute ces trois requêtes suivantes:

1. En utilisant la **directive**  no_index pour forcéer Oracle de ne pas utiliser un index.
    ```sql
    explain plan for
    SELECT /*+  no_index( a IndexAge) */   a.nom, a.prenom
    FROM BigAnnuaire a WHERE a.age > 19;
    @p4
    ```
2. En utilisant la **directive** index pour forcer Oracle à utiiser un index.
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

### Question c) : Pour la requête `age = 18 and cp = 75000` proposer 4 plans équivalents et donner leur coût. Vérifier que le plan de coût minimal est bien celui choisi sans aucune directive.

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
D'après ces quatres exécutions on peut dire qu'on obtient un meilleur coût en forçant l'utilisation des deux indexes. Dans le deuxième rang des meilleurs coût on n'a la deuxième requête qui est la requête que l'utilisation de l'index IndexAge est forcé mais l'utilisation de l'index IndexCp est empéché, puis dans le troisième rang on a la première requête dans laquelle on a forcé l'utilisation de l'index IndexCp et on a empéché l'utilisation de l'inex IndexAge. Et dans le dernier rang on a la dernière requête qu'on a empéché l'utilisation des deux index.

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

## Exercice 4 : Requête de jointure utilisant un index

Il existe une table **Ville** (cp, ville, population) qui contient le nom de la ville pour chaque code postal cp.

Décrire les plans suivants en rédigeant le pseudo-code correspondant au plan. Mettre en évidence les itérations foreach en détaillant sur quel ensemble se fait l'itération et le contenu d'une itération. 

### Question a)
 
La requête donnée dans l'énoncé est le suivant:
```sql
EXPLAIN plan FOR
    SELECT a.nom, a.prenom, v.ville
    FROM Annuaire a, Ville v
    WHERE a.cp = v.cp
    AND a.age=18;
@p3
```

L'exécution de cette requête donne l'affichage suivante:
```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 3467006727

---------------------------------------------------------
| Id  | Operation		     | Name	| Rows	|
---------------------------------------------------------
|   0 | SELECT STATEMENT	     |		|    20 |
|*  1 |  HASH JOIN		     |		|    20 |
|   2 |   TABLE ACCESS BY INDEX ROWID| ANNUAIRE |    20 |
|*  3 |    INDEX RANGE SCAN	     | INDEXAGE |    20 |
|   4 |   TABLE ACCESS FULL	     | VILLE	|  1000 |
---------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("A"."CP"="V"."CP")
   3 - access("A"."AGE"=18)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30],
       "V"."VILLE"[VARCHAR2,30]
   2 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30],
       "A"."CP"[NUMBER,22]
   3 - "A".ROWID[ROWID,10]
   4 - "V"."VILLE"[VARCHAR2,30], "V"."CP"[NUMBER,22]
```

Pseudo-code correspondant au plan : 
```TypeScript
interface HashTable<T> {
    [key: string]: T;
}
interface Ville : {cp:number ,ville:String, population: number}; 
const ville : Ville[];/* On suppose que cette table est bien définie*/
interface Annnuaire: {nom:String,age:number,tel:String,prenom:String,cp;number,profil:String}; 
const annuaire: Annuaire[] /* On suppose que cette table existe aussi*/

let hashT: HashTable<{nom:String,prenom:String,ville:String}> = {}; /* On créé alors un table d'hachage qui est initiliasé à vide */
const indexAge = annuaire.filter(a => a.age === 18); /* On crée un index depuis la table annuaire avec les éléménts de la table dont l'attribut age est égale à 18 */
for (var i = 0; i < indexAge.length; i++)
[
    /* On parcourt cette table par le numéro de la ligne. Et on ajoute les valeurs dans la table d'hachage par l'attribut code postal */
    hashT[indexAge[i.cp].nom = indexAge[i].nom;
    hashT[indexAge[i.cp].prenom = indexAge[i].prenom;
]1

for (var v of ville)
{
    /* On parcourt la table des villes en entière et on les ajoute à la table d'hachage par l'attribut code postal*/
    hashT[v.cp].ville = v.ville;
}

for (var h of hashT)
{
    /* On parcourt la table d'hachage pour afficher les valeurs */
    console.log('' + h.nom + ' ' + h.prenom + ' ' + h.ville);
}
```

### Question b)
La requête donnée en ennoncé est le suivante : 
```sql
explain plan for
    select a.nom, a.prenom, v.ville
    from BigAnnuaire a, Ville v
    where a.cp = v.cp
    and a.age=18;
@p3
```

L'exécution de cette requête donne l'affichage suivante : 
```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 513054719

------------------------------------------------------------
| Id  | Operation		     | Name	   | Rows  |
------------------------------------------------------------
|   0 | SELECT STATEMENT	     |		   |  2200 |
|*  1 |  HASH JOIN		     |		   |  2200 |
|   2 |   TABLE ACCESS FULL	     | VILLE	   |  1000 |
|   3 |   TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE |  2200 |
|*  4 |    INDEX RANGE SCAN	     | INDEXAGE    |  2200 |
------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("A"."CP"="V"."CP")
   4 - access("A"."AGE"=18)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "V"."VILLE"[VARCHAR2,30], "A"."NOM"[VARCHAR2,30],
       "A"."PRENOM"[VARCHAR2,30]
   2 - "V"."VILLE"[VARCHAR2,30], "V"."CP"[NUMBER,22]
   3 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30],
       "A"."CP"[NUMBER,22]
   4 - "A".ROWID[ROWID,10]
```
Pseudo-code correspondant au plan : 
```TypeScript
interface HashTable<T> {
    [key: string]: T;
}
interface Ville : {
                    cp:number,
                    ville:String, 
                    population: number
                }; 
const ville : Ville[];/* On suppose que cette table est bien définie*/
interface BigAnnnuaire: {
                            nom:String,
                            age:number,
                            tel:String,
                            prenom:String,
                            cp;number,
                            profil:String
                        }; 
const bigAnnuaire: BigAnnuaire[] /* On suppose que cette table existe aussi*/
let hashT: HashTable<{nom:String,prenom:String,ville:String}> = {}; /* On créé alors un table d'hachage qui est initiliasé à vide */
for (var v of ville)
{
    /* On parcourt la table des villes en entière et on les ajoute à la table d'hachage par l'attribut code postal*/
    hashT[v.cp].ville = v.ville;
}
const indexAge = bigAnnuaire.filter(ba => { ba.age === 18}); /* On crée ici la table de indexAge qui contient les éléments de BigAnnuaire dont l'attribiut age est égale à 18*/
/* On parcourt la table indexAge par le numéro de ligne */
for (var i = 0; i<indexAge.length; ++)
{
    hashT[indexAge[i].cp].nom = indexAge[î].nom;
    hashT[indexAge[i].cp].prenom = indexAge[i].prenom;
}

for (var h of hashT)
{
    /* On parcourt la table d'hachage pour afficher les valeurs */
    console.log('' + h.nom + ' ' + h.prenom + ' ' + h.ville);
}
```
**Réponse à la question :** Dans la **question a)** la table Annuaire est lue avant la table Ville parce que dans la requête on n'a pas de contrainte sur la table Ville, et donc il va falloir lire tous les lignes donc 1000 lignes présente dans la table Ville. Dans l'autre côté, l'index indexAge nous permet d'avoir 20 lignes à lire concernant la table annuaire. Oracle préfère de lire d'abord le table dont le nombre de lignes le plus petit pour optimiser l'exécution des requêtes. A la question **question b)** la table Ville est lue avant la table BigAnnuaire parce que l'index indeAge sur la table BigAnnuaire nous permet d'avoir 2200 lignes mais dans la table Ville il y a 1000 lignes. Donc de même manière Oracle commence par la table dont le nombre des lignes est le plus petit pour optimiser l'exécution.

### Question c)

La requête donnée dans l'énoncé est la suivante:
```sql
EXPLAIN plan FOR
    SELECT a.nom, a.prenom, v.ville
    FROM BigAnnuaire a, Ville v
    WHERE a.cp = v.cp
    AND v.population >= 985000;
@p3
```

L'exécution de cette requête nous donne l'affichage suivante:
```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 2006762043

------------------------------------------------------------
| Id  | Operation		     | Name	   | Rows  |
------------------------------------------------------------
|   0 | SELECT STATEMENT	     |		   |  3647 |
|   1 |  NESTED LOOPS		     |		   |	   |
|   2 |   NESTED LOOPS		     |		   |  3647 |
|*  3 |    TABLE ACCESS FULL	     | VILLE	   |	17 |
|*  4 |    INDEX RANGE SCAN	     | INDEXCP	   |   220 |
|   5 |   TABLE ACCESS BY INDEX ROWID| BIGANNUAIRE |   220 |
------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("V"."POPULATION">=985000)
   4 - access("A"."CP"="V"."CP")

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=0) "V"."VILLE"[VARCHAR2,30], "A"."NOM"[VARCHAR2,30],
       "A"."PRENOM"[VARCHAR2,30]
   2 - (#keys=0) "V"."VILLE"[VARCHAR2,30], "A".ROWID[ROWID,10]
   3 - "V"."VILLE"[VARCHAR2,30], "V"."CP"[NUMBER,22]
   4 - "A".ROWID[ROWID,10]
   5 - "A"."NOM"[VARCHAR2,30], "A"."PRENOM"[VARCHAR2,30]
```
Pseudo-code correspondant au plan : 
```TypeScript
interface Ville; {cp:number ,ville:String, population: number};
interface BigAnnuaire: {nom:String,age:number,tel:String,prenom:String,cp;number,profil:String};
const ville : Ville[]; /* On suppose que cette table est bien définie*/
const bigAnnnuaire a : BigAnnuaire[]; /* On suppose que cette table existe aussi*/

for (var v of ville.filter(v => v.population >= 985000))
{
    /* On parcourt tout la table Ville en filtrant par le prédicat filter("V"."POPULATION">=985000) donc par les éléments dont l'attribut population est plus grand ou égale à 985000 */
    let indexCp = bigAnnuaire.filter(a => {a.cp === v.cp}); /* On crée un index avec les valeurs de bigAnnuaire dont l'attrbut cp est égalé à l'attribut cp des élements de la table Ville filtré. */
    for (var j = 0; j < indexCp.length; j++)
    {
        /* On parcourt la table des index par le numéro de ligne.*/
        console.log('' + indexCp[j].nom + ' ' + indexCp[j].prenom + ' ' + v.ville)
    }
}
```

## Exercice 5 : Autres requêtes
 Dans cet exercice on vous demande d'expliquer “par vous même” un plan contentant un opérateur qui n'a pas été détaillé en cours. 

### Question a) Requêtes avec group by 

```sql
EXPLAIN plan FOR
    SELECT age, COUNT(*)
    FROM BigAnnuaire a
    GROUP BY age;
@p3
```

#### L'explication de la requête :
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

Donc, l'exécution de la requête commence d'abord un parcour de tous les lignes (donc **220 000**) de la table en les indexant par l'âge (**indexAge**). Puis groupe les résultats par index afin de pouvoir exécutuer `COUNT(*)` qui permet à compter le nombre des lignes pour chaque valeur d'âge.

### Question b) Requêtes avec group by having  

```sql
EXPLAIN plan FOR
    SELECT age, COUNT(*)
    FROM BigAnnuaire a
    GROUP BY age
    HAVING COUNT(*) > 200;
@p3
```

#### L'explication de l'exécution de la requête

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