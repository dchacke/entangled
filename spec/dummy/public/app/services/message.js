'use strict';

angular.module('entangledTest')

.factory('Message', function(Entangled) {
  var entangled = new Entangled('ws://localhost:3000/messages');

  var Message = {
    new: function(params) {
      return entangled.new(params);
    },
    all: function(callback) {
      return entangled.all(callback);
    },
    find: function(id, callback) {
      return entangled.find(id, callback);
    },
    create: function(params, callback) {
      return entangled.create(params, callback);
    }
  };

  return Message;
});
