'use strict'

mssql       = require 'mssql'
_           = require 'lodash'
fs          = require 'fs'
path        = require 'path'
mustache    = require 'mustache'

config =
    user: process.env.USER_NAME
    password: process.env.PASSWORD
    server: process.env.SERVER
    # we dont choose a db, but let the templates dictacte db

root = process.cwd()

# local template cache
TEMPLATES = {}

query = (req, res) ->
    template = req.body.template
    if !TEMPLATES[template]
        TEMPLATES[template] = fs.readFileSync(path.join(root, 'lib/sql', "#{template}.sql"), {encoding: 'utf8'})
    template = mustache.render(TEMPLATES[template], req.body.data)

    connection = new mssql.Connection(config, (err) ->
        res.send 500, err if err
        rq = new mssql.Request(connection) # or: var request = connection.request();
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