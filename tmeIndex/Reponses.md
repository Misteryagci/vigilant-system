 # [TME Index](http://www-bd.lip6.fr/wiki/site/enseignement/master/bdr/tmeindex)
 [**Kaan Yagci**](https://kaanyagci.com) <kaan@kaanyagci.com>

 ## Exercice 1 : Requêtes avec prédicat de séléction

| Nom        | Requête SQL           | égalité  |  inégalité | intervalle |
|:-------------:|:-------------:| :-----:|:-----:|:-----:|:-----:|
| R1 | `SELECT * FROM ...; -- sans WHERE`| non | non | non |  
| AgeEgal | `... WHERE age = 18;` | oui | non    |  non     |  
| AgeInf  | `... WHERE age < 25;` |   non    |   oui    |  non     |  
| AgeSup  | `... WHERE age > 18;` |  non    |   oui   |   non    |  
| AgeEntre| `... WHERE age BETWEEN 18 AND 25;` |  non   |   non    |   oui    |  
| CodeEgal| `... WHERE cp = 75000; ` |   oui    |   non    |   non    |  
| CodeInf | `... WHERE cp < 25000; ` | non |   oui    |   non   |    
| CodeSup | `... WHERE cp > 75000;` | non |   oui    |   non    |        
| CodeEntre| `... WHERE cp BETWEEN 15000 AND 25000; `| non |  non  | oui |
|**Age et Code postal :**  |                         |     |       |     |
| AgeEgalCodeEgal | `... WHERE age = 18 AND cp = 75000;` | oui  | oui | non |
| AgeEgalCodeInf | `... WHERE age = 18 AND cp < 25000;` | oui | oui | non |
|  AgeInfCodeEgal | `... WHERE age < 25 AND cp = 75000;` | oui | oui | non |
| AgeInfCodeInf | `... WHERE age < 25 AND cp < 25000;` | non | non | oui |
| AgeInfCodeEntre | `... WHERE age < 25 AND (cp BETWEEN 15000 AND 25000);` |  non | oui | oui |
|  AgeEntreCodeInf | `... WHERE (age BETWEEN 18 AND 25)  AND cp < 25000;` | non | oui | oui |
|**Age puis dénombrement :**  |                         |     |       |     |
| AgeInfCompte | `SELECT COUNT(*) FROM ... WHERE age < 60;` | non | oui | non |

