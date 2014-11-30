{sh, run} = require './util'

module.exports = class App
  constructor: (site, defaults) ->
    @src = "#{defaults.src}/#{site.id}"
    @dst = "#{defaults.appsRoot}/#{site.id}"
    @dstTmp = @dst + '-tmp'
    @dstDel = @dst + '-del'

  copy: (cb) ->
    run 'mkdir', ['-p', @dst], (err) =>
      run 'rsync', ['-a', '--del', @src + '/', @dstTmp + '/'], cb

  replace: (cb) ->
    sh """
      mv '#{@dst}' '#{@dstDel}' 2>/dev/null || true
      mv '#{@dstTmp}' '#{@dst}'
      rm -fr '#{@dstDel}'
    """, cb
