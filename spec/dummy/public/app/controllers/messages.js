'use strict';

angular.module('entangledTest')

.controller('MessagesCtrl', function($scope, Message) {
  $scope.message = Message.new();

  $scope.create = function() {
    $scope.message.$save(function() {
      $scope.message = Message.new();
    });
  };

  $scope.destroy = function(message) {
    message.$destroy();
  };

  Message.all(function(messages) {
    $scope.$apply(function() {
      $scope.messages = messages;
    });
  });
});
