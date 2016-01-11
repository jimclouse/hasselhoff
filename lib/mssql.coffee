'use strict'

mssql       = require 'mssql'
_           = require 'lodash'
fs          = require 'fs'
path        = require 'path'
mustache    = require 'mustache'

# set up configuration for different servers
CONFIGS = {}
servers = (process.env.CONNECTIONS).split(',') || []

_.each servers, (s) ->
    config = JSON.parse(process.env[s] || '')
    CONFIGS[config.name] = config.config
    CONFIGS[config.name].requestTimeout = 60000

root = process.cwd()

# local template cache
TEMPLATES = {}

query = (req, res) ->
    template = req.body.template
    if !TEMPLATES[template]
        TEMPLATES[template] = fs.readFileSync(path.join(root, 'lib/sql', "#{template}.sql"), {encoding: 'utf8'})
    template = mustache.render(TEMPLATES[template], req.body.data)
    config = CONFIGS[req.body.data.server]

    if !config
        return res.send 500, "Connection for #{req.body.data.server} not found."

    connection = new mssql.Connection(config, (err) ->
        res.send 500, err if err
        rq = new mssql.Request(connection) # or: var request = connection.request();
        rq.multiple = true;
        rq.query(template, (err, recordset) ->
            res.send 500, err if err
            res.send recordset
        )
    )

proc = (req, res) ->
    console.log "not Implemented"
    # Stored Procedure
    # var request = new mssql.Request(connection);
    # request.input('input_parameter', mssql.Int, 10);
    # request.output('output_parameter', mssql.VarChar(50));
    # request.execute('procedure_name', function(err, recordsets, returnValue) ->
    #     // ... error checks

    #     console.dir(recordsets);

module.exports.query = query