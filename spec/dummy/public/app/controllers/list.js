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

      $scope.item = $scope.list.items().new();
      console.log($scope.item);
    });
  });

  $scope.createItem = function() {
    $scope.item.$save(function() {
      $scope.$apply(function() {
        $scope.item = $scope.list.items().new();
      });
    });
  };

  $scope.updateItem = function(event, item) {
    item.$save();
  };
});
