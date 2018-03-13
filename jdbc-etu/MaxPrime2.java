import java.sql.*;
import java.io.*;


/**
 *  NOM, Prenom 1 : YAGCI Kaan
 * La classe MaxPrime
 **/
public class MaxPrime2 {

    String server = "db-oracle.ufr-info-p6.jussieu.fr";
    String port = "1521";
    String database = "oracle";

   // remplacer 1234567 par votre numero
    String user = "E3201099";

    // remplacer 1234567 par votre numero
    String password = "E3201099";

    Connection connexion = null;
    public static PrintStream out = System.out;    // affichage des resulats a l'ecran

    /**
     * methode main: point d'entree
     **/
    public static void main(String a[]) {
        MaxPrime2 c = new MaxPrime2();
	c.traiteRequete();
    }
 
   
    /**
     * Constructeur : initialisation
     **/
    private MaxPrime2(){
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
     */
    public void traiteRequete() {
        try {
            String url = "jdbc:oracle:thin:@" + server + ":" + port + ":" + database;
            out.println("Connexion avec l'URL: " + url);
            out.println("utilisateur: " + user + ", mot de passe: " + password);
                connexion = DriverManager.getConnection(url, user, password);

            /* Commentaire: On demande a l'utilisateur de saisir une valeur pour l'anee ou quitter le programme */
            String a1 = Outil.lireValeur("Saisir une annee ou appuyez sur la touche Entree sans rien saisir pour quitter le programme");
            
            String requete = "select nom, max(prime) from Gain g, Joueur j"
            + " where g.nujoueur = j.nujoueur and annee = ? group by nom";
                
            /* Commentaire: On affiche la chaine des caracteres statement ainsi on cree une variabe lecture de type Statement et on execute la requete sur cette variable lecture */
            out.println("statement...");
            PreparedStatement lecture =  connexion.prepareStatement(requete);
            while ((!a1.equals("")) && (a1 != null)) {
                int i1 = Integer.parseInt(a1);
                lecture.setInt(1,i1);
                out.println("execute la requete : " + requete);
                ResultSet resultat = lecture.executeQuery();
                    
                out.println("resultat...");
                    while (resultat.next()) {
                        String tuple = resultat.getString(1) + "\t" + resultat.getString(2);
                        out.println(tuple);
                    }
                resultat.close();
                a1 = Outil.lireValeur("Saisir une annee ou appuyez sur la touche Entree sans rien saisir pour quitter le programme");
            }
            lecture.close();
            connexion.close();
        }

        /* gestion des exceptions */
        catch(Exception e){ Outil.gestionDesErreurs(connexion, e);}
    }
}
