
app.service 'formatSql', [() ->
    service =
        newlineTerms: ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'FROM', 'WHERE', 'ORDER BY', 'GROUP BY',  'HAVING', 'USE', 'SET']
        newLineTabTerms: ['INNER JOIN', 'CROSS APPLY', 'LEFT JOIN', 'RIGHT JOIN', 'LEFT OUTER JOIN', 'RIGHT OUTER JOIN']      
        format: (tsql) ->
            return unless tsql
            tsql = tsql.replace(';', ';<BR/>')
            _.each @newlineTerms, (n) ->
                tsql = tsql.replace(new RegExp(n, 'gi'), "<BR><span class=\"sql-reserved\">#{n}</span>")
            _.each @newLineTabTerms, (n) ->
                tsql = tsql.replace(new RegExp(n, 'gi'), "<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class=\"sql-reserved\">#{n}</span>")
            tsql

]