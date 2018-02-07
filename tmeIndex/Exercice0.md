# Exercice préliminaire: Statistiques sur les tables

Pour déterminer le plan d'une requête, le SGBD s'appuie sur des statistiques décrivant les données. Les statistiques sont, entre autres, la cardinalité d'une table et le nombre de valeurs distinctes d'un attribut.

Observer les statistiques qu'utilise le SGBD (lire la valeur dans la colonne ROWS).

## La cardinalité d'une table

```sql
EXPLAIN plan FOR
    SELECT * FROM Annuaire;
@p3
```

**Réponse :**
L'exécution retourne le suivant:

```sql
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------
Plan hash value: 1255195813

----------------------------------------------
| Id  | Operation      | Name     | Rows  |
----------------------------------------------
|   0 | SELECT STATEMENT  |         |    2000 |
|   1 |  TABLE ACCESS FULL| ANNUAIRE |    2000 |
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
| Id  | Operation      | Name    | Rows    |
-------------------------------------------------
|   0 | SELECT STATEMENT  |        |   220K|
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

## Pour BigAnnuaire

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