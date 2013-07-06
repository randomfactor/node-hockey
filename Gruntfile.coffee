module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig {
    pkg: grunt.file.readJSON('package.json'),
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build: {
        src: 'src/<%= pkg.name %>.js'
        dest: 'build/<%= pkg.name %>.min.js'
      }
    }

    jasmine_node: {
      forceExit: true
      match: '.'
      matchall: false
      extensions: 'js|coffee'
      useCoffee: true
      specNameMatcher: 'spec'
      jUnit: {
        report: false
        savePath : "./build/reports/jasmine/"
        useDotNotation: true
        consolidate: true
      }
    }
  }

  # Load the plugins
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-jasmine-node')

  grunt.registerTask('default', ['jasmine_node'])
