
app.controller 'dictionary', ($rootScope, $scope, $http, $routeParams, $location) ->

    $scope.dictionary = {}

    fetchTables = () ->
        $http.post('query', {template: "allTablesDictionary", data: {database: $rootScope.selectedDatabase.name}})
            .then (res) ->
                $scope.dictionary.tables = res.data[0]
            .catch (err) ->
                console.error err

    fetchColumns = () ->
        $http.post('query', {template: "getExtendedProperties", data: {database: $routeParams.database, objectId: $routeParams.tableId}})
            .then (res) ->
                $scope.dictionary.table = res.data[0][0]
                $scope.dictionary.columns = res.data[1]
            .catch (err) ->
                console.error err

    $scope.$on('changeDatabase', (message, db) ->
        delete $routeParams.tableId
        $location.path("/dictionary/#{db.name}")
        fetchTables()
    )

    init = () ->
        if $routeParams.tableId
            # get info on one table only
            fetchColumns()
        else
            fetchTables()

    if $rootScope.selectedDatabase
        init()
    else
        $scope.$on('initializedDatabase', (message, event) ->
            init()
        )




