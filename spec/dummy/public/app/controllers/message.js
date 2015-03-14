'use strict';

angular.module('entangledTest')

.controller('MessageCtrl', function($scope, $routeParams, Message) {
  $scope.update = function() {
    $scope.message.$save();
  };

  Message.find($routeParams.id, function(message) {
    $scope.$apply(function() {
      $scope.message = message;
    });
  });
});
