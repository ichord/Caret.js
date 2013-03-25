module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    uglify:
      options:
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      build:
        files:
          'build/<%= pkg.name %>.min.js': ['src/<%= pkg.name %>.js']

    coffee:
      compileWithMaps:
        options:
          sourceMap: true
        files:
          'src/<%= pkg.name %>.js': 'src/<%= pkg.name %>.coffee'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'

  grunt.registerTask 'default', ['coffee', 'uglify']
