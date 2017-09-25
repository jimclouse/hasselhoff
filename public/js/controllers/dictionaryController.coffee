
app.controller 'dictionary', ($rootScope, $scope, $http, $routeParams, $location) ->

    $scope.dictionary = {
        tablesFilterdBy: ''
        tablesFiltered: [],
    }

    destroy$ = new Rx.Subject()

    query = (template, data={}) ->
        data.database = $rootScope.selectedDatabase.name unless data.database
        data.server = $rootScope.selectedServer
        $http.post('query', {template: template, data: data})

    fetchTables = () ->
        query("allTablesDictionary")
            .then (res) ->
                $scope.dictionary.tables = res.data[0]
                filterTables()
            .catch (err) ->
                console.error err

    fetchColumns = () ->
        query("getExtendedProperties", {database: $routeParams.database, objectId: $routeParams.tableId})
            .then (res) ->
                $scope.dictionary.table = res.data[0][0]
                $scope.dictionary.columns = res.data[1]
            .catch (err) ->
                console.error err


    filterTables = () ->
        val = $scope.dictionary.tablesFilterdBy
        tables = $scope.dictionary.tables || []
        tester = new RegExp(val, 'i')
        $scope.dictionary.tablesFiltered =
            if !!val
            then _.filter tables, (table) -> tester.test (table.tableName.replace /^.+\./, '')
            else tables.slice()
        
        $scope.$digest() if !$scope.$$phase


    $scope.$on('changeDatabase', (message, db) ->
        delete $routeParams.tableId
        $location.path("/dictionary/#{db.name}")
        fetchTables()
    )

    $scope.$on('$destroy', () ->
        destroy$.next()
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

    initializeFilterInput = () ->
        Rx.Observable.fromEvent (document.getElementById 'filterByNameInput'), 'input'
            .map (e) -> e.target.value
            .debounceTime 500
            .distinctUntilChanged()
            .takeUntil destroy$
            .subscribe (v) ->
                $scope.dictionary.tablesFilterdBy = v
                filterTables()

    init = () ->
        initializeFilterInput() 
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




