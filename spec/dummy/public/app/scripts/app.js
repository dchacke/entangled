'use strict';

/**
 * @ngdoc overview
 * @name frontendApp
 * @description
 * # frontendApp
 *
 * Main module of the application.
 */
var app = angular.module('frontendApp', [
  'ngAnimate',
  'ngCookies',
  'ngResource',
  'ngRoute',
  'ngSanitize',
  'ngTouch',
  'entangled'
]);
  
app.config(function ($routeProvider) {
  $routeProvider
    .when('/', {
      templateUrl: 'views/messages/index.html',
      controller: 'MessagesCtrl'
    })
    .when('/messages/:id', {
      templateUrl: 'views/messages/show.html',
      controller: 'MessageCtrl'
    })
    .otherwise({
      redirectTo: '/'
    });
});
