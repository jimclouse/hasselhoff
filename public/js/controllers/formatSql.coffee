
app.service 'formatSql', [() ->
    service =
        newlineTerms: ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'FROM', 'WHERE', 'ORDER BY', 'GROUP BY', 'INNER JOIN', 'HAVING', 'CROSS APPLY', 'LEFT JOIN', 'RIGHT JOIN', 'LEFT OUTER JOIN', 'RIGHT OUTER JOIN']
        format: (tsql) ->
            tsql = tsql.replace(';', ';<BR/>')
            _.each @newlineTerms, (n) ->
                tsql = tsql.replace(new RegExp(n, 'g'), "<BR><span class=\"sql-reserved\">#{n}</span>")
            tsql

]