'use strict';

angular.module('entangledTest', [
  'ngRoute',
  'entangled'
])

.config(function($routeProvider) {
  $routeProvider
    .when('/lists', {
      templateUrl: 'views/lists/index.html',
      controller: 'ListsCtrl'
    })
    .when('/lists/:id', {
      templateUrl: 'views/lists/show.html',
      controller: 'ListCtrl'
    })
    .otherwise({
      redirectTo: '/lists'
    });
})
