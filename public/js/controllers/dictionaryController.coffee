
app.controller 'dictionary', ($rootScope, $scope, $http, $routeParams, $location) ->

    $scope.dictionary = {}

    query = (template, data={}) ->
        data.database = $rootScope.selectedDatabase.name unless data.database
        data.server = $rootScope.selectedServer
        $http.post('query', {template: template, data: data})

    fetchTables = () ->
        query("allTablesDictionary")
            .then (res) ->
                $scope.dictionary.tables = res.data[0]
            .catch (err) ->
                console.error err

    fetchColumns = () ->
        query("getExtendedProperties", {database: $routeParams.database, objectId: $routeParams.tableId})
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

    $scope.formatLineBreak = (text) ->
        text.replace(/\n/g, "<br />") if text

    $scope.edit = (obj) ->
        obj.isEditing = true

    $scope.save = (obj) ->
        body = _.cloneDeep(obj)
        body.database = $routeParams.database
        body.description = body.description.replace(/'/g, "''") if body.description
        query("updateExtendedProperties", body)
            .then (res) ->
                obj.isEditing = false
            .catch (err) ->
                console.error err

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




