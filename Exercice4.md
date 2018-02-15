# Exercice 4 : Requête de jointure utilisant un index

Il existe une table **Ville** (cp, ville, population) qui contient le nom de la ville pour chaque code postal cp.

Décrire les plans suivants en rédigeant le pseudo-code correspondant au plan. Mettre en évidence les itérations foreach en détaillant sur quel ensemble se fait l'itération et le contenu d'une itération.

## Question a)

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
interface Annuaire: {nom:String,age:number,tel:String,prenom:String,cp;number,profil:String};
const annuaire: Annuaire[] /* On suppose que cette table existe aussi*/

let hashT: HashTable<{l: {nom:String,prenom:String}[],ville:String}> = {}; /* On créé alors un table d'hachage qui est initialisé à vide */
const indexAge = annuaire.filter(a => a.age === 18); /* On crée un index depuis la table annuaire avec les éléments de la table dont l'attribut age est égale à 18 */
for (var i = 0; i < indexAge.length; i++)
{
    /* On parcourt cette table par le numéro de la ligne. Et on ajoute les valeurs dans la table d'hachage par l'attribut code postal */
    hashT[indexAge[i.cp]].l.push({
                                    nom:indexAge[i].nom,
                                    prenom:indexAge[i].prenom
                                }); 
}

for (var v of ville)
{
    /* On parcourt la table des villes en entière et on les ajoute à la table d'hachage par l'attribut code postal*/
    hashT[v.cp].ville = v.ville;
}

for (var h of hashT)
{
    /* On parcourt la table d'hachage pour afficher les valeurs */
    for (l1 of h.l)
    {
        console.log('' + l1.nom + ' ' + l1.prenom + ' ' + h.ville);
    }
}
```

## Question b)

La requête donnée en énoncé est le suivante :

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
interface BigAnnuaire: {
                            nom:String,
                            age:number,
                            tel:String,
                            prenom:String,
                            cp;number,
                            profil:String
                        };
const bigAnnuaire: BigAnnuaire[] /* On suppose que cette table existe aussi*/
let hashT: HashTable<{
                        l:{
                            nom:String,
                            prenom:String
                        }[],
                        ville:String
                    }> = {}; /* On créé alors un table d'hachage qui est initialisé à vide */
for (var v of ville)
{
    /* On parcourt la table des villes en entière et on les ajoute à la table d'hachage par l'attribut code postal*/
    hashT[v.cp].ville = v.ville;
}
const indexAge = bigAnnuaire.filter(ba => { ba.age === 18}); /* On crée ici la table de indexAge qui contient les éléments de BigAnnuaire dont l'attribut age est égale à 18*/
/* On parcourt la table indexAge par le numéro de ligne */
for (var i = 0; i<indexAge.length; ++)
{
    hashT[indexAge[i].cp].l.push({
                                    nom:indexAge[î].nom,
                                    prenom:indexAge[i].prenom
                                });
}

for (var h of hashT)
{
    /* On parcourt la table d'hachage pour afficher les valeurs */
    for (l1 of h.l)
    {
        console.log('' + l1.nom + ' ' + l1.prenom + ' ' + h.ville);
    }
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
const bigAnnuaire a : BigAnnuaire[]; /* On suppose que cette table existe aussi*/

for (var v of ville.filter(v => v.population >= 985000))
{
    /* On parcourt tout la table Ville en filtrant par le prédicat filter("V"."POPULATION">=985000) donc par les éléments dont l'attribut population est plus grand ou égale à 985000 */
    let indexCp = bigAnnuaire.filter(a => {a.cp === v.cp}); /* On crée un index avec les valeurs de bigAnnuaire dont l'attribut cp est égalé à l'attribut cp des éléments de la table Ville filtré. */
    for (var j = 0; j < indexCp.length; j++)
    {
        /* On parcourt la table des index par le numéro de ligne.*/
        console.log('' + indexCp[j].nom + ' ' + indexCp[j].prenom + ' ' + v.ville)
    }
}
```