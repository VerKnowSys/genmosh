# © Copyright 2012 Daniel (dmilith) Dettlaff.
#

express = require 'express'
fs = require 'fs'
pty = require "pty.js"


app_port = 51233
app_name = "genmosh"
home_prefix = "/Users/"
mosh_client_command = "mosh-client"
mosh_server_command = "mosh-server"
mosh_command_params = ["--", "svdshell"]
mosh_server_host_ip = "78.46.95.147"
mosh_keyfile = "mosh.authkey" 
mosh_terminal_cols = 80
mosh_terminal_rows = 30
mosh_matcher = /MOSH CONNECT (\d+?) ([\w*|\/|\+]+)/
default_redirect_site = "http://www.verknowsys.com/"


app = module.exports = express.createServer()


app.configure ->
  app.use express.bodyParser()
  app.use app.router


app.post '/auth/:uid/:uuid', (req, res) ->
  uid = req.params.uid
  uuid = req.params.uuid
  file_path = "#{home_prefix}#{uid}/#{mosh_keyfile}"
  fs.readFile file_path, (err, input_data) ->
    if err
      console.error "Bad try with UID: #{uid}, UUID: #{uuid}!"
      res.redirect default_redirect_site
    else
      data = input_data.toString().trim()
      console.log "Found authkey for UID: #{uid} -> UUID: #{uuid} in #{home_prefix}#{uid}/#{mosh_keyfile}"
      if uuid == data
        console.log "Matched authkey for UID: #{uid} -> #{data} == #{uuid}"
        mosh_command_params.push(uid) # it's only required for ServeD Shell
        term = pty.spawn "#{mosh_server_command}", mosh_command_params,
          cols: mosh_terminal_cols
          rows: mosh_terminal_rows
        
        term.stdout.on "data", (data) ->
          result = "#{data}".trim().match mosh_matcher
          if result
            mosh_port = result[1]
            mosh_key = result[2]
            res.send "MOSH_KEY=#{mosh_key} #{mosh_client_command} #{mosh_server_host_ip} #{mosh_port}\n"
        
      else
        console.error "Bad try with invalid match of #{data} vs #{uuid}"
        res.redirect default_redirect_site


app.get '*', (req, res) ->
  res.redirect default_redirect_site

app.post '*', (req, res) ->
  res.redirect default_redirect_site


app.listen app_port
console.log "#{app_name} listening on port: #{app.address().port}"
