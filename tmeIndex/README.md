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
| <kbd>Alt</kbd>+<kbd>x</kbd>`my/sql-oracle` ou <kbd>Alt</kbd>+<kbd>x</kbd> `sql-oracle` | [se connecter à Oracle.](http://www-bd.lip6.fr/wiki/site/enseignement/documentation/oracle/connexionoracle) |
| aller sur la ligne contenant @annuaire et faire <kbd>Ctrl</kbd>+<kbd>c</kbd> <kbd>Ctrl</kbd>+<kbd>c</kbd> | définir la table Annuaire et un synonyme pour la table BigAnnuaire |

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

**Remarque 1 :**  pour régler l'affichage plus ou moins détaillé d'un plan, remplacer `@p3` par le niveau de détail souhaité allant de 1 à 5 : de `@p1` (plan peu détaillé) jusqu'à `@p4` (plan avec son coût) ou `@p5` (plan avec tous les détails).

**Remarque2 :** **Problème d'affichage trop long**. si par erreur vous avez lancé l'exécution d'une requête en oubliant l'entête explain plan for vous pourriez être gêné par l'affichage de plusieurs milliers de nuplets. Vous pouvez stopper la requête : cliquer dans la fenêtre nommée `*SQL*` puis cliquer sur le menu Signals→BREAK
 
## [Exercice préliminaire: Statistiques sur les tables](Exercice0.md)

## [Exercice 1:  Requête de sélection utilisant un index](Exercice1.md)

## [Exercice 2 : Sélection AVEC OU SANS index](Exercice2.md)

## [Exercice 3. Comparaison de plans d'exécutions équivalents](Exercice3.md)

## [Exercice 4 : Requête de jointure utilisant un index](Exercice4.md)

## [Exercice 5 : Autres requêtes](Exercice5.md)

## Questions fréquentes

- Emacs : avant d'exécuter une requête (avec <kbd>Ctrl</kbd>+<kbd>c</kbd> <kbd>Ctrl</kbd>+<kbd>c</kbd>) vérifier qu'elle est bien suivie d'une ligne **entièrement vide** ne contenant aucun espace.

- Directives d'optimisation : attention à la syntaxe. Ne pas confondre les caractères étoile * du commentaire et celui du select étoile. La ligne contient 3 caractères étoiles. Le caractère plus + est collé au premier caractère étoile.

```sql
    SELECT /*+ directive */ *
    FROM 
    WHERE
```

S'il y a une erreur de syntaxe dans une directive Oracle ignore la directive **SANS** vous avertir.

- Error: **cannot fetch last explain plan** from plan_table : il y a une erreur de syntaxe dans votre requête. La requête n'a pas pu être analysée par oracle. Corriger la requête.

- La cardinalité estimée (ROWS) d'un opérateur semble être celle de l'opérateur parent. Pour certaines opérations binaires, la cardinalité de l'opération est indiquée sur le fils de droite plutôt que sur l'opération elle même.