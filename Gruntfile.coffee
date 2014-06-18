
'use strict'

module.exports = (grunt) ->

  files = (src, dest) ->
    return [{ expand: yes, cwd: 'assets/', src: [src], dest: dest }]

  require 'coffee-script'
  require 'coffee-errors'

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-csslint'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  # grunt.loadNpmTasks 'grunt-contrib-imagemin'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-coffee-lint'
  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-express'
  grunt.loadNpmTasks 'grunt-notify'

  grunt.registerTask 'jsbuild', ['copy:js', 'coffee_lint', 'coffee']
  grunt.registerTask 'cssbuild', ['copy:css', 'stylus', 'csslint']
  grunt.registerTask 'imgbuild', ['copy:img']
  grunt.registerTask 'build', ['imgbuild', 'cssbuild', 'jsbuild', 'jade']

  grunt.registerTask 'test', ['build', 'simplemocha']
  grunt.registerTask 'default', ['build', 'connect', 'watch']
  # grunt.registerTask 'appserve', ['build', 'express', 'watch']

  fs = require 'fs'
  url = require 'url'
  path = require 'path'

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    copy:
      img:
        files: [{ expand: yes, cwd: 'assets/', src: [ '**/*.{jpg,png,gif}' ], dest: 'dist/' }]
      js:
        files: [{ expand: yes, cwd: 'assets/', src: [ '**/*.{js,coffee}' ], dest: 'dist/' }]
      css:
        files: [{ expand: yes, cwd: 'assets/', src: [ '**/*.css' ], dest: 'dist/' }]

    coffee:
      options:
        sourceMap: yes
        sourceRoot: './'
      dist:
        files: [{ expand: yes, cwd: 'assets/', src: [ '**/*.coffee' ], dest: 'dist/', ext: '.js' }]

    stylus:
      dist:
        options:
          compress: off
        files: [{ expand: yes, cwd: 'assets/', src: [ '**/*.styl' ], dest: 'dist/', ext: '.css' }]
      release:
        options:
          compress: on
        files: [{ expand: yes, cwd: 'assets/', src: [ '**/*.styl' ], dest: 'public/', ext: '.css' }]

    jade:
      dist:
        options:
          pretty: on
          data: version: '<%- pkg.version %>'
        files: [{ expand: yes, cwd: 'assets/', src: [ '**/*.jade' ], dest: 'dist/', ext: '.html' }]
      release:
        options:
          pretty: off
          data: version: '<%- pkg.version %>'
        files: [{ expand: yes, cwd: 'assets/', src: [ '**/*.jade' ], dest: 'public/', ext: '.html' }]

    coffee_lint:
      options:
        max_line_length: value: 79
        indentation: value: 2
        newlines_after_classes: level: 'error'
        no_empty_param_list: level: 'error'
        no_unnecessary_fat_arrows: level: 'ignore'
        globals: [ '$', 'console', 'Backbone', 'winow' ]
      all:
        files: [{ expand: yes, cwd: 'assets/', src: [ '**/*.coffee' ] }]

    csslint:
      options:
        import: 2
        'adjoining-classes': off
        'box-sizing': off
        'box-model': off
        'compatible-vendor-prefixes': off
        'floats': off
        'font-sizes': off
        'gradients': off
        'important': off
        'known-properties': off
        'outline-none': off
        'qualified-headings': off
        'regex-selectors': off
        'text-indent': off
        'unique-headings': off
        'universal-selector': off
        'unqualified-attributes': off
      dist:
        src: 'dist/**/*.css'

    uglify:
      dist:
        options:
          mangle: on
        files: [{ expand: yes, cwd: 'dist/', src: [ '**/*.js' ], dest: 'public/', ext: '.js' }]

    imagemin:
      dist:
        files: [{ expand: yes, cwd: 'dist/', src: [ '**/*.{jpg,png,gif}' ], dest: 'public/' }]

    simplemocha:
      options:
        ui: 'bdd'
        reporter: 'spec'
        compilers: 'coffee:coffee-script'
        ignoreLeaks: no
      tests:
        src: [ 'tests/*.coffee' ]

    watch:
      options:
        livereload: yes
        interrupt: yes
      imgbuild:
        files: ['assets/**/*.{jpg,png,gif}']
        tasks: ['imgbuild']
      jsbuild:
        files: ['assets/**/*.coffee']
        tasks: ['jsbuild']
      cssbuild:
        files: ['assets/**/*.styl']
        tasks: ['cssbuild']
      jadebuild:
        files: ['assets/*.jade']
        tasks: ['jade']

    express:
      appserve:
        server: path.resolve __dirname, 'app.js'

    # connect:
    #   server:
    #     options:
    #       port: 3000
    #       middleware: (connect, options) ->
    #         mw = [connect.logger 'dev']
    #         mw.push (req, res) ->
    #           index = path.resolve 'public', 'index.html'
    #           route = path.resolve 'public', (url.parse req.url).pathname.replace /^\//, ''
    #           fs.exists route, (exist) ->
    #             fs.stat route, (err, stat) ->
    #               return fs.createReadStream(route).pipe(res) if exist and stat.isFile()
    #               return fs.createReadStream(index).pipe(res)
    #         return mw
