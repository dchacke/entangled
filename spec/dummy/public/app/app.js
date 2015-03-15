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
    })
    .when('/messages/:id', {
      templateUrl: 'views/messages/show.html',
      controller: 'MessageCtrl'
    })
    .when('/lists', {
      templateUrl: 'views/lists/index.html',
      controller: 'ListsCtrl'
    })
    .when('/lists/:id', {
      templateUrl: 'views/lists/show.html',
      controller: 'ListCtrl'
    })
    .otherwise({
      redirectTo: '/'
    });
})
