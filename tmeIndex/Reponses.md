 # [TME Index](http://www-bd.lip6.fr/wiki/site/enseignement/master/bdr/tmeindex)
 [**Kaan Yagci**](https://kaanyagci.com) <kaan@kaanyagci.com>

## Exercice préliminaire:Statistiques sur les tables
Pour déterminer le plan d'une requête, le SGBD s'appuie sur des statistiques décrivant les données. Les statistiques sont, entre autres, la cardinalité d'une table et le nombre de valeurs distinctes d'un attribut.

Observer les statistiques qu'utilise le SGBD (lire la valeur dans la colonne ROWS).

La cardinalité d'une table : 

```sql
EXPLAIN plan FOR
    SELECT * FROM Annuaire;
@p3
```
**Réponse :** 
L'exécution retourne le suivant.
```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 1255195813

----------------------------------------------
| Id  | Operation	  | Name     | Rows  |
----------------------------------------------
|   0 | SELECT STATEMENT  |	     |	2000 |
|   1 |  TABLE ACCESS FULL| ANNUAIRE |	2000 |
----------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "ANNUAIRE"."NOM"[VARCHAR2,30], "ANNUAIRE"."PRENOM"[VARCHAR2,30],
       "ANNUAIRE"."AGE"[NUMBER,22], "ANNUAIRE"."CP"[NUMBER,22],
       "ANNUAIRE"."TEL"[VARCHAR2,10], "ANNUAIRE"."PROFIL"[VARCHAR2,1500]
```
D'après cet affichage on peut observer que la table Annuaire contient donc 2000 lignes et contient 6 colonnes qui sont les suivants **NOM** qui a comme type VARCHAR2 et qui a comme longueur maximale 30, **PRENOM** qui comme type VARCHAR2 et qui a comme longueur maximale 30, , **AGE** qui a comme type NUMBER et qui a comme longueur maximal 22, **CP** qui est de type NUMBER et qui a comme longueur maximal 22, **TEL** qui est de type VARCHAR2 et qui a comme longueur maximal 10, **PROFIL** qui est de type VARCHAR2 et qui a comme longueur maximal 1500. 


```sql
EXPLAIN plan FOR
    SELECT * FROM BigAnnuaire;
@p3
```
**Réponse :**
L'éxécution retourne le suivant:
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

   1 - "BIGANNUAIRE"."NOM"[VARCHAR2,30],
       "BIGANNUAIRE"."PRENOM"[VARCHAR2,30], "BIGANNUAIRE"."AGE"[NUMBER,22],
       "BIGANNUAIRE"."CP"[NUMBER,22], "BIGANNUAIRE"."TEL"[VARCHAR2,10],
       "BIGANNUAIRE"."PROFIL"[VARCHAR2,4000]
```

D'après cet affichage on peut observer que la table BigAnnuaire contient 220 000 lignes et contient 6 colonnes comme suivants : **NOM** qui est de type VARCHAR2 et de longueur maximal 30, **PRENOM** qui est de type VARCHAR2 et de longueur maximal 30, **AGE** qui est de type NUMBER et de longueur maximal 22, **CP** qui est de type NUMBER et longueur maximal 22, **TEL** qui est de type VARCHAR2 et de longueur maximal 10 et **PROFIL** qui est de type VARCHAR2 et de longueur maximal 4000.

 **Pour BigAnnuaire** 

```sql
EXPLAIN plan FOR
    SELECT DISTINCT nom FROM BigAnnuaire;
@p3
```

Ce requête nous permet de afficher les statistiques sur les valeurs distinct de l'attribut nom de la table BigAnnuaire.

**Résultat :**
On obtient l'affichage suivant:
```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 3079465304

--------------------------------------------------
| Id  | Operation	   | Name	 | Rows  |
--------------------------------------------------
|   0 | SELECT STATEMENT   |		 |   100 |
|   1 |  HASH UNIQUE	   |		 |   100 |
|   2 |   TABLE ACCESS FULL| BIGANNUAIRE |   220K|
--------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "NOM"[VARCHAR2,30]
   2 - "NOM"[VARCHAR2,30]
```
Cet affichage nous indique que le requête SELECT a sélectionné 100 lignes parmi les 220 000 grâce à l'opération HASH UNIQUE qui vient de DISTINCT. Donc le nombre des lignes retourné par ce requête est 100, alors **le nombre des valeurs distinct de l'attribut nom est 100**.

```sql
explain plan for
    select distinct prenom from BigAnnuaire;
@p3
```

Ce requête nous permet d'afficher les statistiques concernant les valeus distincts de l'attribut prenom dans la table BigAnnuire.

**Résultat**
L'exécution du requête donne l'affichage suivant :
```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 3079465304

--------------------------------------------------
| Id  | Operation	   | Name	 | Rows  |
--------------------------------------------------
|   0 | SELECT STATEMENT   |		 |    90 |
|   1 |  HASH UNIQUE	   |		 |    90 |
|   2 |   TABLE ACCESS FULL| BIGANNUAIRE |   220K|
--------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "PRENOM"[VARCHAR2,30]
   2 - "PRENOM"[VARCHAR2,30]
```
D'après cet affichage on peut observer que le DISTINCT permet de sélectionner que 90 lignes parmis les 220 000. Donc on peut dire que **le nombre des valeurs distinct de l'attribut prenom est 90**

```sql
explain plan for
    select distinct age from BigAnnuaire;
@p3
```
Ce requête permet de afficher les statistiques concernant le nombre de valeurs distinct de l'attribut age de la table BigAnnuaire.
**Résultat :** Ce requête nous retourne l'affichage suivant.

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 1724242494

--------------------------------------------------
| Id  | Operation	      | Name	 | Rows  |
--------------------------------------------------
|   0 | SELECT STATEMENT      | 	 |   100 |
|   1 |  HASH UNIQUE	      | 	 |   100 |
|   2 |   INDEX FAST FULL SCAN| INDEXAGE |   220K|
--------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "AGE"[NUMBER,22]
   2 - "AGE"[NUMBER,22]
```
D'après cet affichage on peut observer que DISTINCT nous permet de sélectionner 100 lignes parmi les 220 000. Alors on peut dire que **le nombre des valeurs distinct de l'attribut age est 100.**

```sql
explain plan for
    select distinct cp from BigAnnuaire;
@p3
```

Ce requête nous permet d'afficher les statistiques sur les valeurs distincts de l'attribut cp dans la table BigAnnuaire.

**Résultat :** L'exécution nous retourne l'affichage suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 2161319487

-------------------------------------------------
| Id  | Operation	      | Name	| Rows	|
-------------------------------------------------
|   0 | SELECT STATEMENT      | 	|  1000 |
|   1 |  HASH UNIQUE	      | 	|  1000 |
|   2 |   INDEX FAST FULL SCAN| INDEXCP |   220K|
-------------------------------------------------

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=1) "CP"[NUMBER,22]
   2 - "CP"[NUMBER,22]
```

D'après cet affichage on peut observer que DISTINCT nous permet de retourner 1000 lignes parmis les 220 000. Donc on peut dire que **le nombre des valeurs distinct de l'attribut est 1000.**

### REMARQUE
Pour chaque requête qui sélectionne les valeurs distincts d'un attribut sql crée l'index en utilisant cet attribut en question, pour pouvoir filtrer les données distinctes. La création de l'index est fait automatiquement.

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



