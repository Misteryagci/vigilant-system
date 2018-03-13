import java.sql.*;
import java.io.*;
import java.util.*;

/**
 *  NOM, Prenom 1 : YAGCI Kaan
 * La classe MaxPrime
 **/
public class MaxPrimeParPays {

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
        MaxPrimeParPays c = new MaxPrimeParPays();
	c.traiteRequete();
    }
 
   
    /**
     * Constructeur : initialisation
     **/
    private MaxPrimeParPays(){
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

	        String recupereNationalites = "select distinct j.Nationalite from Joueur j";

            Statement lectureNationalites =  connexion.createStatement();
            
            ResultSet lesNationalites = lectureNationalites.executeQuery(recupereNationalites);
            ArrayList<String> nationalites = new ArrayList<String>();
            System.out.println("Recuperation des nationalites...");
            while (lesNationalites.next()) {
                String tuple = lesNationalites.getString(1);
                nationalites.add(tuple);
            }
            System.out.println("Le nombre des nationalites " + nationalites.size());
            String recupereLeJoueurMax = "select j.nom, j.prenom, Max(g.prime) from Joueur j, Gain g WHERE j.NuJoueur = g.NuJoueur AND j.Nationalite = ? GROUP BY (prenom,nom)";
            PreparedStatement lectureJoueurMax = connexion.prepareStatement(recupereLeJoueurMax);
            for (String nationalite : nationalites) {
                System.out.println("Nationalite = " + nationalite);
                lectureJoueurMax.setString(1,nationalite);
                ResultSet lesJoueurMax = lectureJoueurMax.executeQuery();
                while(lesJoueurMax.next()) {
                    String t = lesJoueurMax.getString(1) + "\t" + lesJoueurMax.getString(2) + "\t" + lesJoueurMax.getString(3);
                    System.out.println(t);
                }
                lesJoueurMax.close();
            }
        lectureJoueurMax.close();
	    lesNationalites.close();
	    lectureNationalites.close();
	    connexion.close();
        }

        /* gestion des exceptions */
        catch(Exception e){ Outil.gestionDesErreurs(connexion, e);}
    }
}
