'use strict'

mssql   = require 'mssql'
_       = require 'lodash'

config =
    user: process.env.USER_NAME
    password: process.env.PASSWORD
    server: process.env.SERVER

query = (req, res) ->
    statement = req.body.stmt
    db = req.body.db

    cfg = _.clone config
    cfg.database = db if db
    connection = new mssql.Connection(cfg, (err) ->
        res.send 500, err if err
        rq = new mssql.Request(connection) # or: var request = connection.request();
        rq.query(statement, (err, recordset) ->
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