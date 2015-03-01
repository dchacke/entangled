// Created with the help of
// http://paislee.io/testing-angularjs-with-grunt-karma-and-jasmine/

module.exports = function(grunt) {

  grunt.loadNpmTasks('grunt-karma');

  grunt.initConfig({
    karma: {  
      unit: {
        options: {
          frameworks: ['jasmine'],
          singleRun: true,
          browsers: ['Chrome'], // 'PhantomJS'
          files: [
            'bower_components/angular/angular.js',
            'bower_components/angular-route/angular-route.js',
            'bower_components/angular-mocks/angular-mocks.js',
            'app/**/*.js',
            'test/**/*.js'
          ]
        }
      }
    }
  });

  grunt.registerTask('test', [  
    'karma'
  ]);
};
