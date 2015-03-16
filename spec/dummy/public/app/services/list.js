'use strict';

angular.module('entangledTest')

.factory('List', function(Entangled) {
  var List = new Entangled('ws://localhost:3000/lists');
  List.hasMany('items');
  return List;
});
