module.exports = function(grunt) {

  grunt.loadNpmTasks('grunt-karma');

  grunt.initConfig({
    jshint: {
      files: ['Gruntfile.js', 'js/**/*.js', 'test/**/*.js'],
    },
    watch: {
      tasks: ['karma']
    },
    karma: {  
      unit: {
        options: {
          frameworks: ['jasmine'],
          singleRun: true,
          browsers: ['PhantomJS'],
          files: [
            'bower_components/angular/angular.js',
            'bower_components/angular-route/angular-route.js',
            'bower_components/angular-mocks/angular-mocks.js',
            'js/**/*.js',
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
