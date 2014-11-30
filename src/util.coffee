{exec, spawn} = require 'child_process'

exports.sh = (cmds, cb) ->
  exec cmds, (err, stdout, stderr) ->
    process.stdout.write stdout + stderr
    cb err

exports.run = (name, args, cb) ->
  p = spawn name, args
  p.stdout.on 'data', (data) -> process.stdout.write data
  p.stderr.on 'data', (data) -> process.stderr.write data
  p.on 'close', (code) ->
    return cb 'code-' + code unless code is 0
    cb()
