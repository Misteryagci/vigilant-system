# Exercice 6: Documentation

Vous pouvez interroger le dictionnaire du SGBD pour obtenir des informations détaillées sur vos tables et vos index.

## **Description d'un index** : profondeur de l'arbre, nombre de valeurs indexées. Interroger [user_indexes](http://docs.oracle.com/cd/B19306_01/server.102/b14237/statviews_1069.htm#i1578369)

```sql
SELECT index_name, blevel, distinct_keys FROM user_indexes;
``` 

L'exécution de cette requête retourne le suivant:

```sql
INDEX_NAME     BLEVEL DISTINCT_KEYS
---------- ---------- -------------
INDEXAGE	    1		100
INDEXCP 	    1		855

2 ligne(s) sélectionnée(s).
```

On peut voir d'après l'affichage qu'il y a deux indexes présents qui sont les suivants: `indexAge` et `indexCp`. Ces deux indexes sont définis sur la table ANNUAIRE. L'index `indeAge` contient 100 clés distinctes et l'index `indexCP` contient 855 clés distinctes.

## **Description d'une table** : cardinalité, taille totale. Interroger [user_tables](http://docs.oracle.com/cd/B19306_01/server.102/b14237/statviews_2105.htm#REFRN20286)

```sql
SELECT TABLE_NAME, num_rows, blocks FROM user_tables;
```

L'exécution de cette requête retourne l'affichage suivante

```sql
TABLE_NAME		 BLOCKS   NUM_ROWS
-------------------- ---------- ----------
VILLE			      5       1000
ANNUAIRE		    622       2000

2 ligne(s) sélectionnée(s).
```

On peut observer d'après l'affichage qu'il y a deux tables qui sont la table **VILLE** et la table **ANNUAIRE**. La table **VILLE** contient 5 blocks ainsi que 1000 lignes. La table **ANNUAIRE** contient 622 blocks ainsi et 2000 lignes.

## **Description d'un attribut** : valeur min, max, nb de valeurs disctinctes. Interroger [user_tab_cols](http://docs.oracle.com/cd/B19306_01/server.102/b14237/statviews_2093.htm#I1020276) 

```sql
COLUMN TABLE_NAME format A20
COLUMN column_name format A20
SELECT TABLE_NAME, column_name, utl_raw.cast_to_number(low_value) AS borneInf,  utl_raw.cast_to_number(high_value) AS borneSup, num_distinct, histogram
FROM user_tab_cols
WHERE data_type = 'NUMBER';
```

L'exécution de cette requête retourne l'affichage suivante:

```sql
TABLE_NAME	     COLUMN_NAME	    BORNEINF   BORNESUP NUM_DISTINCT
-------------------- -------------------- ---------- ---------- ------------
HISTOGRAM
---------------------------------------------
ANNUAIRE	     AGE			   1	    100 	 100
NONE

ANNUAIRE	     CP 			1000	 100900 	 855
NONE

VILLE		     CP 			1000	 100900 	1000
NONE

VILLE		     POPULATION 		2000	1000000 	 646
NONE


4 ligne(s) sélectionnée(s).
```

D'après l'affichage on peut dire que la requête nous a renvoyé plus précisement une histogramme. On peut dire que cette histogramme contient 4 entrées de 2 tables différentes qui sont les suivantes: 

- **La colonne `AGE` depuis la table `ANNUAIRE`** ; Cette colonne contient 100 valeurs distinctes et ces valeurs sont compris dans l'intervalle [1,100].
- **La colonne `CP` depuia la table `ANNUAIRE`** : Cette colonne contient 855 valeurs distinctes et ces valeurs sont comptris dans l'intervalle [100,100900]
- **La colonne `CP` depuis la table `VILLE`** : Cette colonne contient 1000 valeurs distinctes et ces valeurs sont compris dans l'intervalle [100,100900]
- **La colonne `POPULATION` depuis la table `VILL`** : Cette colonne contient 646 valeurs différentes et ces valeurs sont compris dans l'intervalle [200,1000000]

 etc… de nombreuses autres informations sont disponibles tq par exemple l'histogramme représentant la distribution des valeurs d'un attribut. Voir la [liste des vues](http://docs.oracle.com/cd/B19306_01/nav/catalog_views.htm#index-USE) que vous pouvez interroger.