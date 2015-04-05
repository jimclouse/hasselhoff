app.controller 'main', ($scope, $http) ->

    query = (template) ->
        $http.post('/query', {template: template, database: 'glglive'})
            .then (res) ->
                return res.data
            .catch (err) ->
                console.error err


    query('get_databases').then (data) -> $scope.databases = data