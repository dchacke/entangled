'use strict';

angular.module('entangledTest')

.factory('Message', function(Entangled) {
  return new Entangled('ws://localhost:3000/messages');
});
