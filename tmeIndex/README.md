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
 
## [Exercice préliminaire: Statistiques sur les tables](Exercice0.md)

## [Exercice 1:  Requête de sélection utilisant un index](Exercice1.md)

## [Exercice 2 : Sélection AVEC OU SANS index](Exercice2.md)

## [Exercice 3. Comparaison de plans d'exécutions équivalents](Exercice3.md)

## [Exercice 4 : Requête de jointure utilisant un index](Exercice4.md)

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