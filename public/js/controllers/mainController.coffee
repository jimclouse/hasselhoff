app.controller 'main', ($scope, $http) ->

    query = (template) ->
        $http.post('/query', {template: template, database: 'glglive'})
            .then (res) ->
                return res.data
            .catch (err) ->
                console.error err

    # initialize
    query('get_databases').then (data) -> 
        $scope.databases = data
        $scope.selectedDatabase = _.first _.filter data, (d) -> d.name == 'master'

    query('get_sysprocesses').then (data) -> $scope.processes = data    