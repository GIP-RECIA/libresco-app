# Tests

Flutter dispose de deux types de tests qui sont mis en oeuvre dans ce projet. Ce document détaille leur fonctionnement.

## Tests unitaires

Les tests unitaires se trouvent dans le dossier `test`. Au moment de l'écriture de ce document ils ne sont pas encore ajoutés.

## Tests d'intrégation

Les tests d'intégrations se basent sur une librairie spécifique `Patrol`. Cette librairie est nécéssaire car elle permet d'intéragir directement dans les webviews, ce qui n'est pas possible avec le module de tests d'intégration de base de flutter.

Les tests d'intégrations sont déposés dans le dossier `integration_test` à la racine du projet (ce nom est obligatoire pour que flutter les considère comme des tests unitaires). Un test se compose de la manière suivante :

```dart
void main() {
  patrolTest('Nom du test', ($) async {
    // Lancement de l'application
    final widget = await app.buildApp();
    await $.pumpWidgetAndSettle(widget);

    // Ensuite deux possibilités
    // Soit on vérifie l'état dans lequel on se trouve avec un expect, exemple :
    expect($(UnconnectedHomePage), findsOneWidget);

    // Soit on réalise une action
    // Exemple pour une interaction avec un widget flutter
    await $(#loginButton).tap();
    await $.pumpAndSettle();

    // Exemple pour une interaction dans une webview
    await $.native.tap(Selector(resourceId: 'autres-publics'));
  }
}
```

Pour lancer les tests d'intégration il faut :
- Lancer un émulateur et le choisir ;
- Faire la commande : `patrol test -t integration_test/nom_test.dart` ;
- Le scénario de tests va alors s'éxécuter dans l'émulateur : le résultat du test sera indiqué dans la console.

**Important** : 
- Pour l'instant patrol ne fonctionne pas avec des devices au-dessus de l'API **34** (voir https://github.com/leancodepl/patrol/issues/2476).
- Les tests d'intégrations ont été configurés pour fonctionner sur Android mais pas encore sous IOS (voir https://patrol.leancode.co/documentation#faq à l'étape 5)


Actuellement l'application dipose d'un test d'intgération qui simule une ouverture de l'application avec connexion, accès aux services puis déconnexion. Celui-ci se nomme `full_test.dart`.