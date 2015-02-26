'use strict';

angular.module('entangledTest', [
  'ngRoute',
  'entangled'
])

.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      templateUrl: 'views/messages/index.html',
      controller: 'MessagesCtrl'
    }).when('/messages/:id', {
      templateUrl: 'views/messages/show.html',
      controller: 'MessageCtrl'
    })
    .otherwise({
      redirectTo: '/'
    });
})

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
    }
  };

  return Message;
})

.controller('MessagesCtrl', function($scope, Message) {
  $scope.message = Message.new();

  $scope.create = function() {
    $scope.message.$save();
  };

  $scope.destroy = function(message) {
    message.$destroy();
  };

  Message.all(function(messages) {
    $scope.$apply(function() {
      console.log('Index callback called!');
      $scope.messages = messages;
    });
  });
})

.controller('MessageCtrl', function($scope, $routeParams, Message) {
  $scope.update = function() {
    $scope.message.$save();
  };

  Message.find($routeParams.id, function(message) {
    $scope.$apply(function() {
      $scope.message = message;
      console.log('Show callback called!');
    });
  });
})
