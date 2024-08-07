// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:application_gestion_des_reclamations_pfe/Application%20etudiant/auth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEtudiant extends StatefulWidget {
  const ProfileEtudiant({super.key});

  @override
  State<ProfileEtudiant> createState() => _ProfileEtudiantState();
}

class _ProfileEtudiantState extends State<ProfileEtudiant> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //liste des fillieres
  List<String> _filieres = [
    'Sciences Mathématiques Appliquées (SMA)',
    'Sciences Mathématiques Informatiques (SMI)',
    'Sciences de la Matière Physique (SMP)',
    'Sciences de la Matière Chimie (SMC)',
    'Sciences de la Vie (SVI)',
    "Sciences de la Terre et de l'Univers (STU)",
  ];

  //declaration des variables
  String? _selectedFiliere;
  String? _imageURL;
  String? _selectedSexe;

  String nom = '';
  String prenom = '';
  String apoge = '';
  String filiere = '';
  String sexe = '';
  String? email = '';

//declaration des controllers
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _apogeController = TextEditingController();

//lafonction initialisation
  @override
  void initState() {
    super.initState();
    _loadApoge(); // Chargement de l'apogée au démarrage de la page
    _nomController.text = nom; // Initialisation du contrôleur du nom
    _prenomController.text = prenom; // Initialisation du contrôleur du prénom
    _apogeController.text = apoge; // Initialisation du contrôleur de l'apogée
  }

  //lafonction de get apoge d etuidant connecte
  Future<void> _loadApoge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? apoge = prefs.getString('apogeConnecte');
    if (apoge != null) {
      setState(() {
        this.apoge = apoge;
      });
    } else {
      print('No apoge found in SharedPreferences');
    }
  }

//la fonction de deconnexion
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Déconnexion de Firebase Auth
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(
          'apogeConnecte'); // Suppression de l'apogée dans SharedPreferences
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Login()), // Assurez-vous que LoginPage() est correctement importé
      );
      print("connexion reussite !!!!:)  pour " + nom + "  " + prenom);
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 84, 132, 196),
        title: Row(children: [
          SizedBox(width: 120),
          Text(
            "Mon profil",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
        ]),
        /* actions: [
          ElevatedButton(
            onPressed: _logout,
            child: Icon(Icons.logout),
            style: ButtonStyle(iconSize: MaterialStatePropertyAll(15)),
          ),
          SizedBox(width: 10),
        ],*/
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('etudiantsActives')
            .where('apoge', isEqualTo: apoge)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No data found for the given apoge."));
          }

          var data = snapshot.data!.docs.first.data();
          nom = data['nom'] ?? '';
          prenom = data['prenom'] ?? '';
          apoge = (data['apoge'] ?? '').toString();
          filiere = data['filiere'] ?? '';
          sexe = data['sexe'] ?? '';

          // Mise à jour des contrôleurs avec les nouvelles données
          _nomController.text = nom;
          _prenomController.text = prenom;
          _apogeController.text = apoge;
          _selectedFiliere = filiere;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Center(
                // Photo de profil
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: SizedBox(
                      width: 220,
                      height: 200,
                      child: Image.asset(
                        sexe == 'Masculin'
                            ? 'images/profile_masculin.png'
                            : 'images/profile_feminin.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),

              SizedBox(height: 15),
              // Bouton pour éditer la photo de profil

              SizedBox(height: 15),
              AfficherInformationEtudiant('Nom', nom, 18, 40),
              AfficherInformationEtudiant('Prenom', prenom, 18, 40),
              AfficherInformationEtudiant('Apoge', apoge, 18, 40),
              AfficherInformationEtudiant('Filiere', filiere, 18, 65),
              AfficherInformationEtudiant('Sexe', sexe, 16, 40),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(left: 250),
                child: Container(
                  child: ElevatedButton(
                    onPressed: () {
                      // Action à exécuter lorsque le bouton est pressé
                      _showEditModal(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromARGB(255, 84, 132, 196),
                    ),
                    child: Text("Modifier"),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Padding AfficherInformationEtudiant(
      String label, String valeur, double taille, double toul) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 5),
          Text(
            "$label :",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 84, 132, 196),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 8, right: 8, top: 12),
              height: toul,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromARGB(255, 238, 116, 17),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  ' $valeur ',
                  style: TextStyle(
                    fontSize: taille,
                    color: Color.fromARGB(255, 55, 105, 172),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditModal(BuildContext context) {
    String? _selectedFiliere = _filieres.first;

    String? localSelectedFiliere = _selectedFiliere;
    String localSexe = sexe;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modifier les informations',
                    style: TextStyle(
                      color: Color.fromARGB(255, 55, 105, 172),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nomController,
                      style: TextStyle(
                      color: Color.fromARGB(255, 55, 105, 172), // Couleur du texte dans le TextField
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(
                            255, 238, 116, 17), // Couleur du texte du label
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 238, 116,
                              17), // Couleur de la bordure par défaut
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 238, 116,
                              17), // Couleur de la bordure lorsqu'elle est sélectionnée
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _prenomController,
                      style: TextStyle(
                      color: Color.fromARGB(255, 55, 105, 172), // Couleur du texte dans le TextField
                    ),
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(
                            255, 238, 116, 17), // Couleur du texte du label
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 238, 116,
                              17), // Couleur de la bordure lorsqu'elle est sélectionnée
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _apogeController,
                    style: TextStyle(
                      color: Color.fromARGB(255, 55, 105,
                          172), // Couleur du texte dans le TextField
                    ),
                    decoration: InputDecoration(
                      labelText: 'Apogée',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(
                            255, 238, 116, 17), // Couleur du texte du label
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 238, 116,
                              17), // Couleur de la bordure lorsqu'elle est sélectionnée
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedFiliere,
                    items: _filieres.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                              color: Color.fromARGB(255, 55, 105, 172), // Couleur du texte dans le TextField 
                              fontSize:14
                              ), // Définir la taille de la police ici
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedFiliere = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Filière',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(
                            255, 238, 116, 17), // Couleur du texte du label
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 238, 116,
                              17), // Couleur de la bordure lorsqu'elle est sélectionnée
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedSexe,
                    items: ['Masculin', 'Féminin'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                         style: TextStyle(
          color:  Color.fromARGB(255, 55, 105, 172), // Couleur du texte du contenu du champ
        ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSexe = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Sexe',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(
                            255, 238, 116, 17), // Couleur du texte du label
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 238, 116,
                              17), // Couleur de la bordure lorsqu'elle est sélectionnée
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 84, 132,
                              196), // Couleur de fond de votre choix
                        ),
                      ),
                      onPressed: () {
                        _updateStudentInfo();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Enregistrer',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateStudentInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? apogeConnecte = prefs.getString('apogeConnecte');
      if (apogeConnecte == null) {
        print('No apoge found in SharedPreferences');
        return; 
      }

      // Récupérer l'ID du document correspondant à l'apogée 20035326
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('etudiantsActives')
          .where('apoge', isEqualTo: apogeConnecte)
          .get();

      // Vérifier si un document correspondant à l'apogée 20035326 a été trouvé
      if (snapshot.docs.isEmpty) {
        print('No document found for apoge ' + apogeConnecte);
        return;
      }

      // Mettre à jour le document avec les nouvelles valeurs des champs d'entrée
      await snapshot.docs.first.reference.update({
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'apoge': _apogeController.text,
        'filiere': _selectedFiliere,
        'sexe': _selectedSexe,
      });

      setState(() {
        nom = _nomController.text;
        prenom = _prenomController.text;
        apoge = _apogeController.text;
        filiere = _selectedFiliere!;
        sexe = _selectedSexe!;
      });
      // Afficher un message de réussite ou effectuer toute autre action nécessaire
    } catch (error) {
      // Gérer l'erreur si nécessaire
      print("Failed to update student info: $error");
    }
  }
}
