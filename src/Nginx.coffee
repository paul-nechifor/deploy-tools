fs = require 'fs'
{sh} = require './util'

module.exports = class Nginx
  constructor: (@site, @defaults) ->

  getContent: ->
    @site.nginx.replace /\[\[\[([^\]]*)\]\]\]/g, (match, p1) =>
      name = p1.trim()
      @site[name] or @defaults[name]

  removeDefault: (cb) ->
    sh """
      rm -f /etc/nginx/sites-enabled/default
      rm -f /etc/nginx/sites-available/default
    """, cb

  write: (cb) ->
    file = '/etc/nginx/sites-available/' + @site.id
    fs.writeFile file, @getContent(), {encoding: 'utf8'}, (err) =>
      return cb err if err
      sh """
        cd /etc/nginx/sites-enabled
        rm -f '#{@site.id}'
        ln -s ../sites-available/'#{@site.id}' '#{@site.id}'
      """, cb

  restart: (cb) ->
    sh "service nginx restart", cb
