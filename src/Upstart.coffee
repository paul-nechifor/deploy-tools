fs = require 'fs'
path = require 'path'
{sh} = require './util'

module.exports = class Upstart
  constructor: (@site, @defaults) ->
    @binary = @site.binary or @defaults.binaries[@site.appType]
    @description = @site.description or @site.id + ' web server'
    @author = @site.author or 'author'
    @respawnLimit = @site.respawnLimit or [5, 60]

  getContent: ->
    ret = '#!upstart\n\n'

    ret += "description \"#{@description}\"\n" if @description
    ret += "author \"#{@author}\"\n" if @author

    ret += 'start on startup\nstop on shutdown\n'

    ret += "setuid #{@site.uid}\n" if @site.uid
    ret += "setgid #{@site.gid}\n" if @site.gid

    ret += 'respawn\n'
    ret += "respawn limit #{@respawnLimit.join ' '}\n" if @respawnLimit

    script = path.resolve @defaults.appsRoot, @site.id, @site.script

    ret += """
      script
          exec #{@binary} #{script} >> /var/log/#{@site.id} 2>&1
      end script
    """

    ret

  write: (cb) ->
    content = @getContent()
    file = "/etc/init/#{@site.id}.conf"
    fs.writeFile file, content, {encoding: 'utf8'}, cb

  restart: (cb) ->
    sh "service #{@site.id} restart", cb
