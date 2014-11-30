async = require 'async'

exports.globalDefaults =
  src: '/opt/synced/apps'
  appsRoot: '/opt/apps'
  binaries:
    node: '/usr/bin/node'

exports.App = require './App'
exports.Upstart = require './Upstart'
exports.Nginx = require './Nginx'

exports.install = (site, cb) ->
  app = new exports.App site, exports.globalDefaults
  upstart = new exports.Upstart site, exports.globalDefaults
  nginx = new exports.Nginx site, exports.globalDefaults

  async.series [
    [app, 'copy']
    [upstart, 'write']
    [nginx, 'write']
    [nginx, 'removeDefault']
    [app, 'replace']
    [upstart, 'restart']
    [nginx, 'restart']
  ].map ((a) -> a[0][a[1]].bind(a[0])), cb
