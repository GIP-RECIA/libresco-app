# Appels à l'API du portail

Pour récupérer la liste des services de l'utilisateur et faire fonctionner les composants web, le portail est une pièce centrale. Il faut déjà pouvoir établir une session (voir Authentication.md), car il faudra envoyer le cookie de session pour toutes les requêtes au portail. Les interactions avec le portail sont regroupées dans le `PortalService`.

## Liste des services

La liste des services est chargée par la méthode `getAllPortlets()` grâce à une requête sur l'endpoint `/portail/api/v4-3/dlm/portletRegistry.json`. Il y a ensuite un travail de parsing de la réponse pour récupérer les données qui nous intéressent afin de mettre à jour la liste des services. La mise à jour s'effectue directement sur un objet Singleton `Service` qui contient 2 listes : `servicesList` pour les services et `favoritesList` pour les favoris. C'est ce singleton qui sera utilisé par les différentes classes chargées de construire l'UI.

## Mise en favori des services

2 méthodes sont utilisées pour la mise en favori des services :
- `switchPortletIsFavoriteState` qui est la méthode appelée depuis l'exterieur, elle inclus la logique de mise à jour des favoris. Il faut à la fois mettre à jour la liste du singleton `Service`, mais aussi mettre à jour la base côté portail qui stocke les favoris ;
- `requestSwitchPortletIsFavoriteState` qui est est une méthode interne qui réalise l'appel à l'API pour mettre à jour les favoris côté portail. L'appel se fait sur l'endpoint `/portail/api/layout` avec des paramètres particuliers :
```
{
    'action': service.isFavorite ? 'removeFavorite': 'addFavorite',
    'channelId': service.id.toString()
}
```

## Récupération des user infos

La méthode  `loadUserInfo` permet de mettre à jour les infos utilisateurs. Pour cela elle fait appel à la méthode `getUserInfo` qui réalise un appel API sur vers `/portail/api/v5-1/userinfo`. Les user infos sont utiles lorsqu'on a besoin d'afficher directement dans des widgets flutters des informations sur l'utilisateur (nom, photo, établissement courant, etc...).

## Composants web

Les composants web du portail sont disposés directement dans une `WebView`. Pour qu'ils fonctionnent, il suffit d'importer le `js` puis de déclarer la balise du composant web avec les bons paramètres. Grâce au système de gestion de sessions, le composant web pourra demander une soffit au portail et communiquer avec lui comme dans un navigateur web classique car on a le cookie `JSESSIONID` dans la `WebView`.