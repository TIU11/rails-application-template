window.TIU = window.TIU || {};

TIU.app = angular.module('myApp', ['ngResource', 'ngAnimate', 'ngSanitize', 'ui.bootstrap']);

//
// Configure (Providers are available)
//
TIU.app
  .config(function($httpProvider) {
    // Required for 1.1.x as per https://github.com/angular/angular.js/issues/1004
    // Rails won't know to return JSON without this.
    $httpProvider.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
  })
;
