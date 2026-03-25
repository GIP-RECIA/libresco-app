# Authentification

L'application mobile dispose d'une persistance spécifique des sessions afin d'éviter à l'utilisateur d'avoir à tout le temps se reconnecter. Cette persistance est mise en œuvre grâce à une sauvegarde des cookies de session (portail et CAS) dans une base de données. Ces cookies sont ensuite restitués lors des requêtes en ayant besoin, que ce soit des requêtes directes avec un `HttpClient` ou des requêtes faites par une `WebView`.

## Flot

Le schéma ci-dessous résume tout le flot d'authentification :

![[images/authentication_flow.png]](images/authentication_flow.png)

## Obtention des cookies

### Cookie CAS

Pour obtenir le cookie CAS, on ouvre un `InAppBrowser` modifié sur l'url de login du CAS avec le service spécifique de l'application mobile. L'utilisateur arrive sur le WAYF et peut se connecter comme il le ferait normalement. Pour déterminer la fin du processus de connexion, et donc quand on doit passer à la suite, on vérifie l'url de chaque requête qui est faite. Lorsqu'on tombe sur une url de validation de ticket, alors cela veut dire que la session CAS a été établie : l'idée est alors de parcourir tous les cookies du navigateur grâce au `CookieManager` jusqu'à tomber sur le TGC. Cette logique se trouve dans la méthode `onLoadStart` qui peut se simplifier de la manière suivante :

```dart
Future onLoadStart(url) async {  
 if(url de validation de ticket) {  
  recuperation du cookie TGC
  enregistrement dans la base de données
  if(TGC) {  
   fermer le navigateur
   aller sur l'accueil connecté
  else {  
   retour sur l'accueil non connecté 
  }
 }
}
```

**Note** : si on n'obtient pas le cookie TGC alors que l'url de validation du ticket à été appelée, c'est que flutter n'a pas réussi à le récupérer (même s'il est dans les cookies du navigateur). Cela peut survenir sur certaines vieilles versions des navigateurs, ce qui laisse supposer une incompatibilité au niveau de la librairie `# flutter_inappwebview` utilisée.

### Cookie portail

Le cookie portail se récupère avec des requêtes en direct sur le portail via un `HttpClient`, il n'y a pas besoin d'interaction utilisateur. Ces appels doivent se faire avec le cookie CAS obtenu précédemment pour permettre au portail de créer la session. On récupère les cookies directement depuis les headers des réponses. La logique est dans la méthode `unstackedUPortalLogin`.

**Note** : comme on a plusieurs portails il y a 2 cookies à sauvegarder : le `JSESSIONID` et le `clusterIDPortail`.

## Vérification de la validité des sessions

Pour éviter de se retrouver bloqué dans un cas où on n'arrive pas à établir de session, on vérifie à plusieurs endroits dans le flot si les sessions portail et CAS sont encore valides. On se sert de 2 méthodes dans le `LoginService` qui sont accessibles de partout (car c'est un singleton).

### Session CAS

On vérifie la validité de la session CAS grâce à une requête `GET` toute simple sur le `/cas/login`. Si on est connecté, le CAS doit répondre une page spécifique après connexion. Si on n'est pas connecté on serait redirigé vers le WAYF. C'est grâce à cette distinction qu'en analysant le body de la réponse on peut savoir si l'utilisateur est connecté ou non.

Le code se trouve dans la méthode `hasCASSession()`.

### Session portail

On vérifie la validité de la session portail grâce à une requête sur l'endpoint `/api/session.json` du portail. Si on est connecté, le portail doit donner en réponse un JSON avec une `sessionKey` qui ne doit pas être nulle. Si elle est nulle ou qu'on reçoit un code d'erreur, alors cela veut dire que l'utilisateur n'a pas de session portail. A noter qu'on peut établir une nouvelle session portail même si elle est expirée, tant que la session CAS est encore valide, tout en gardant l'opération transparente pour l'utilisateur.

Le code se trouve dans la méthode `hasPortalSession()`.

## Stockage en base de données

On utilise 2 classes pour stocker et accéder aux cookies de la base de données :

- `TokenRepository` qui communique directement avec la base. C'est la classe qui fait les requêtes de création de table, de récupération des données, d'ajout ou de suppression ;
- `TokenManager` qui l'interface utilisée dans le reste de l'application lorsqu'on a besoin d'accéder aux cookies ou de mettre à jour leurs valeurs. C'est un singleton qui stocke les cookies dans la mémoire de l'application après les avoir récupéré depuis la base de données. Il peut lancer des sauvegarde en base à partir de ses données, et on peut aussi mettre à jour ses valeurs depuis la base de données (grâce la méthode `getCookiesInDB`);

## Restitution des cookies

Une fois les cookies récupérés et stockés en base, il faut pouvoir les restituer aux bons endroits. La restitution se passe le plus souvent dans des `WebView` grâce au `CookieManager`. C'est un singleton qui permet de gérer les cookies utilisées par toutes les instances de `WebView`. On accède à cet objet depuis les différentes classes ou c'est nécessaires et il ensuite de faire un `setCookie` avec les bons paramètres (exemple pour un cookie CAS) :

```dart
manager.setCookie(
  url: WebUri("${AppConfig().casBaseURL}/cas"),  
  name: "TGC",  
  value: TokenManager().TGC,  
  isHttpOnly: true,  
  isSecure: true,  
  sameSite: HTTPCookieSameSitePolicy.NONE,  
  domain: AppConfig().casHost,  
  path: "/cas",  
);
```

**Note** : on peut faire un `manager.deleteAllCookies()` pour remettre à zéro les cookies avant de les ajouter : cela permet de nettoyer le `CookieManager` pour être sur que d'anciens cookies potentiellement invalides sont bien supprimés.

## Serveur CAS

D'autres modifications moins importantes permettent d'assurer un fonctionnement optimal de la persistance des sessions, notamment :

- La définition d'un user-agent spécifique et unique partout dans l'application mobile, afin de ne pas avoir à retirer le système de`pin-to-session` au niveau du serveur CAS ;
- Une configuration spécifique au niveau du serveur CAS pour autoriser des
sessions plus longues spécifiquement pour ce service, avec un système de soft/hard timeout ajouté pour l'occasion.
