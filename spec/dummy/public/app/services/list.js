'use strict';

angular.module('entangledTest')

.factory('List', function(Entangled) {
  var entangled = new Entangled('ws://localhost:3000/lists');
  entangled.hasMany('items');
  return entangled;
});
