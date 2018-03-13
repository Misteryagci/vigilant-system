import java.sql.*;
import java.io.*;


/**
 *  NOM, Prenom 1 : YAGCI Kaan 
 *
 * La classe Joueur
 **/
public class Joueur {
    
    /*Commentaire: 
    * On initialise une classe Joueur qui contient les manipulations sur la table Joueur. 
    * On commence par initialiser le numéro du port, l'adresse du serveur ainsi que la base des données 
    */
    
    String server = "db-oracle.ufr-info-p6.jussieu.fr";
    String port = "1521";
    String database = "oracle";

    // remplacer 1234567 par votre numéro
    String user = "E3201099";

    // remplacer 1234567 par votre numéro
    String password = "E3201099";
    
    String requete = "select nom, prenom from Joueur";

    Connection connexion = null;
    public static PrintStream out = System.out;    // affichage des résulats à l'ecran
    
    /**
     * methode main: point d'entrée
     **/
    public static void main(String a[]) {

        /* Commentaire: On initialise une instance de la classe Joueur. Sur cet instance on exécute la requête de base initialisé au début de la classe. */
        Joueur c = new Joueur();
        
	c.traiteRequete();
    }
    
    /**
     * Constructeur : initialisation
     **/
    protected Joueur(){
        try {

            /* Chargement du pilote JDBC */
	    Class.forName("oracle.jdbc.driver.OracleDriver");
        }
        catch(Exception e) {
            Outil.erreurInit(e);
        }
    }
        
    /**
     *  La methode traiteRequete
     *
     *  Commentaire : Cette méthode permet d'exécuter une requête sur la table Joueur.
     *
     */
    public void traiteRequete() {
        try {

            /* Commentaire: On commence par se connecter à la base Oracle */
	    String url = "jdbc:oracle:thin:@" + server + ":" + port + ":" + database;
            connexion = DriverManager.getConnection(url, user, password);
            
            /* Commentaire: Une fois que la connexion est faite, on créate une communication (une instance de la classe Statement) pour pouvoir en suite exéucter notre réquête dessus */
            Statement lecture =  connexion.createStatement();
            
            /* Commentaire: Une fois qu'on a créé la communication on exécute notre requête sur cette communication et on stocke son résultat dans une variable resultat de type ResultSet */
            ResultSet resultat = lecture.executeQuery(requete);
            
            /* Commentaire: 
            * On commence à lire le résultat obtenu, pour cela on parcours la variable result un par un et on récupère la chaîne des caractères en premier et deuxième position 
            * et on les stocke dans un variable tuple de type String en séparant par une tabulation et on suite on affiche le conteu de la variable tuple 
            * pour chaque élément de la variable result 
            */
            while (resultat.next()) {
                String tuple = resultat.getString(1) + "\t" + resultat.getString(2);
                out.println(tuple);
            }

            /* Commentaire: On ferme tous les connexion qu'on a créé précédemment*/
	    resultat.close();
	    lecture.close();
	    connexion.close();
        }

        /* Commentaire: On récupère toutes les expections liée à la connexion */
        catch(Exception e){ Outil.gestionDesErreurs(connexion, e);}
    }
}
