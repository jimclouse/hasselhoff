#! stuff
mssql =     require 'mssql'

config =
    user: 'user'
    password: 'password'
    server: 'host'
    database: 'database'
    pool:
        max: 10
        min: 0
        idleTimeoutMillis: 30000

connection = new mssql.Connection(config, (err) ->
    # add error handling
    # Query
    request = new mssql.Request(connection) # or: var request = connection.request();
    request.query('select name from sys.tables;', (err, recordset) ->
        # ... error checks
        console.log recordset

        # Stored Procedure

        # var request = new mssql.Request(connection);
        # request.input('input_parameter', mssql.Int, 10);
        # request.output('output_parameter', mssql.VarChar(50));
        # request.execute('procedure_name', function(err, recordsets, returnValue) ->
        #     // ... error checks

        #     console.dir(recordsets);
        # 
    )
)