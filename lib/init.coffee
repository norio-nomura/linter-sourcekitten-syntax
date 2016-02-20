module.exports =
  config:
    sourcekittenExecutablePath:
      type: 'string'
      title: 'the path to SourceKitten'
      default: '/usr/local/bin/sourcekitten'

  activate: ->
    require('atom-package-deps').install('linter-sourcekitten-syntax')

  provideLinter: ->
    helpers = require('atom-linter')
    path = require('path')
    fs = require('fs-plus')
    provider =
      grammarScopes: ['source.swift']
      scope: 'file'
      lintOnFly: true
      lint: (textEditor) ->
        input = textEditor.getText()
        buffer = textEditor.getBuffer()
        filePath = textEditor.getPath()

        command = atom.config.get('linter-sourcekitten-syntax.sourcekittenExecutablePath')
        return unless fs.existsSync(command)
        parameters = ['syntax', '--text', input]
        options = {throwOnStdErr: false}

        syntaxResult = helpers.exec(command, parameters, options).then (output) ->
          syntaxTokens = JSON.parse output
          syntaxTokens.map (token) ->
            {
              type: 'info',
              text: "[#{token.offset}, #{token.length}] " + token.type,
              filePath: filePath
              range: [
                buffer.positionForCharacterIndex(token.offset),
                buffer.positionForCharacterIndex(token.offset + token.length)
              ]
            }
