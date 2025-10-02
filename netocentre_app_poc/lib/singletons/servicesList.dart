import 'package:netocentre_app_poc/entities/service.dart';
import 'package:slugify/slugify.dart';

class Services {
  static final Services _instance = Services._internal();
  List<Service> _list = [];
  List<Service> _favoritesList = [];

  factory Services() {
    return _instance;
  }
  
  Services._internal();

  List<Service> get servicesList => _list;

  setServicesList(List<Service> newList){
    List<Service> neewList = _sort(newList);
    _list = _sort(neewList);
  }

  addToServicesList(Service service){
    _list.add(service);
  }

  List<Service> get favoritesList => _favoritesList;

  setFavoritesList(List<Service> newList){
    _favoritesList = _sort(newList);
  }

  _sort(List<Service> list){
    list.sort((a,b) => slugify(a.text).compareTo(slugify(b.text)));
    return list;
  }
}