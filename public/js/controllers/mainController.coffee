app.controller 'main', ($scope, $http) ->

    query = (template) ->
        $http.post('/query', {template: template, database: 'glglive'})
            .then (res) ->
                return res.data
            .catch (err) ->
                console.error err

    # initialize
    $scope.page = 'main'
    query('get_databases').then (data) -> 
        $scope.databases = data
        $scope.selectedDatabase = _.first _.filter data, (d) -> d.name == 'master'


    $scope.fetchQuery = (template) ->
        query(template).then (data) -> 
            $scope.infos = data            
            $scope.partial = template.replace('get_', '')
