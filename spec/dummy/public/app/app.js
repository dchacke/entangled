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
