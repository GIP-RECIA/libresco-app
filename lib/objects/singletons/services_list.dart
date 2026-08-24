// Copyright (C) 2023 GIP-RECIA, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:libresco/objects/service.dart';
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

  void setServicesList(List<Service> newList) {
    List<Service> neewList = _sort(newList);
    _list = _sort(neewList);
  }

  void addToServicesList(Service service) {
    _list.add(service);
  }

  List<Service> get favoritesList => _favoritesList;

  void setFavoritesList(List<Service> newList) {
    _favoritesList = _sort(newList);
  }

  List<Service> _sort(List<Service> list) {
    list.sort((a, b) => slugify(a.text).compareTo(slugify(b.text)));
    return list;
  }
}
