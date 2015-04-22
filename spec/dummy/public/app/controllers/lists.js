'use strict';

angular.module('entangledTest')

.controller('ListsCtrl', function($scope, List) {
  $scope.list = List.new();

  $scope.create = function() {
    $scope.list.$save(function() {
      $scope.$apply(function() {
        $scope.list = List.new();
      });
    });
  };

  $scope.destroy = function(list) {
    list.$destroy();
  };

  List.all(function(err, lists) {
    $scope.$apply(function() {
      $scope.lists = lists;
    });
  });
});
