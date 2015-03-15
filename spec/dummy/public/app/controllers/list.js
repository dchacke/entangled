'use strict';

angular.module('entangledTest')

.controller('ListCtrl', function($scope, $routeParams, List) {
  List.find($routeParams.id, function(list) {
    $scope.$apply(function() {
      $scope.list = list;
      $scope.list.items().all(function(items) {
        $scope.$apply(function() {
          $scope.items = items;
        });
      });
    });
  });
});
