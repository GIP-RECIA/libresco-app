# netocentre_app_poc

POC de l'application mobile, avec la partie backend (gestion de session, appels API au portail) et la partie frontend (widgets flutters, webviews).

## Prérequis

- Flutter (channel stable, `3.35.5` au moment de l'écriture)
- Dart `3.9.2+`
- Java `17+`

Au besoin faire un `flutter doctor` pour vérifier si tout est bien configuré.

## Architecture

- Une base de données
- Plusieurs `StatefulWidget` :
  - Pages entières
  - Composants
  - Webviews
- Un `InAppBrowser` pour l'authentification CAS
- Des services pour accéder à la base de données, réaliser le flot de login et les requêtes à l'API du portail
- Des tests unitaires et des tests d'intégrations (TODO)

## Build et run en local

Le mieux pour faire tourner le projet en local est d'utiliser Android Studio avec les plugin `Flutter` et `Dart`. Il suffit alors de séléctionner un émulateur ou téléphone si branché en local, et de lancer le `main.dart`. 