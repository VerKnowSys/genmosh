# © Copyright 2012 Daniel (dmilith) Dettlaff.
#

express = require 'express'
fs = require 'fs'
pty = require "pty.js"

app_port = 51233
app_name = "genmosh"
default_lag = 1000 # in ms
server_shell_command = "/bin/svdshell"
mosh_default_timeout = 60000 # in ms
mosh_user_limit_logged_in_at_once = 5
mosh_client_command = "mosh-client"
mosh_server_command = "mosh-server"
mosh_server_host_ip = "78.46.95.147"
mosh_terminal_cols = 80
mosh_terminal_rows = 30
mosh_matcher = /MOSH CONNECT (\d+?) ([\w*|\/|\+]+)/
default_redirect_site = "http://www.verknowsys.com/"
home_prefix = "/SystemUsers/"
public_prefix = "/Public/"
mosh_keyfile = "mosh.keys"
mosh_socketfile = "mosh_auth.socket"
listen_on = "#{public_prefix}#{mosh_socketfile}" # this might be also TCP port

logged_in_users = [] # logged in user record


move_out = (res, message = null) ->
  setTimeout ->
      if message
        res.send message
      else
        res.redirect default_redirect_site
    , default_lag


app = module.exports = express.createServer()


app.configure ->
  app.use express.bodyParser()
  app.use app.router


app.post '/auth/:uuid', (req, res) ->
  uuid = req.params.uuid
  file_path = "#{home_prefix}#{mosh_keyfile}"
  fs.readFile file_path, (err, input_data) ->
    if err
      move_out res
    else
      input_objects = JSON.parse "#{input_data}"
      input_objects.map (object) ->
        if uuid.indexOf(object.sha) > -1
          data = object.sha
          uid = object.uid
      
          console.log "* Matched valid authkey for UID: #{uid} from IP: #{req.connection.remoteAddress} -> #{uuid} in #{home_prefix}#{mosh_keyfile}"
          
          logged_in_users[uid] = [] unless logged_in_users[uid] # add info about logged in user
          if logged_in_users[uid].length < mosh_user_limit_logged_in_at_once
            logged_in_users[uid].push uuid
            console.log "* Logged in users with UID #{uid}: #{logged_in_users[uid].length}"
            term = pty.spawn "#{mosh_server_command}", ["--", "#{server_shell_command}", uid],
              cols: mosh_terminal_cols
              rows: mosh_terminal_rows
            setTimeout -> # after mosh session timeout, we may try log in again
                logged_in_users[uid].pop()
                console.log "* Popped passkey for UID: #{uid}. Logged in users with this UID: #{logged_in_users[uid].length}"
              , mosh_default_timeout
            term.stdout.on "data", (data) ->
              result = data.match mosh_matcher
              if result
                mosh_port = result[1]
                mosh_key = result[2]
                res.send "MOSH_KEY=#{mosh_key} #{mosh_client_command} #{mosh_server_host_ip} #{mosh_port}\n"
          else
            move_out res, "Reached maximum amount of logins (#{mosh_user_limit_logged_in_at_once}). Please retry later. (~#{mosh_default_timeout/1000}s)\n"


app.get '*', (req, res) ->
  move_out res

app.post '*', (req, res) ->
  move_out res


app.listen listen_on
console.log "#{app_name} listening on socket: #{listen_on}"
