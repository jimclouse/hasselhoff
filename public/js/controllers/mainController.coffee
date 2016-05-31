
app.controller 'main', ($rootScope, $scope, $http, $timeout, formatSql, $routeParams, $location) ->

    ## Navigation Methods
    $scope.navigateBack = () ->
        navStack.pop()
        p = navStack.slice(-1)[0]
        if p.template in ['main', 'system', 'maintenance']
            $scope.partial = null
            $scope.pageCahce = null
        else
            $scope.partial = p.template
        $scope.nav.page = p.template
        $scope.infos = p.infos

    $scope.navigate = (obj) ->
        navStack.push(obj)
        $scope.nav.page = obj.template

    setNavData = (infos) ->
        navStack[navStack.length - 1].infos = infos

    # use the stored pageCache info to re-run the current query
    refresh = $scope.refresh = () ->
        $scope.partial = 'loading'
        topOfStack = navStack.slice(-1)[0]
        fetchQuery(topOfStack?.template, topOfStack?.data, topOfStack.processFn)

    $scope.goHome = () ->
        navStack = []
        $scope.nav.page = 'main'
        $scope.partial = null
        $location.path("/")


    ## Top level Server / DB methods
    getDatabaseList = () ->
        $rootScope.databases = [] # clear out the existing
        query('allDatabases').then (data) ->
            $rootScope.databases = data[0]
            seed = 'master'
            #seed = $routeParams.database if $routeParams.database
            $rootScope.selectedDatabase = _.first _.filter data[0], (d) -> d.name == seed
            $rootScope.$broadcast('initializedDatabase', 'm')

    $scope.changeDatabase = changeDatabase = () ->
        #$rootScope.selectedDatabase = $scope.selectedDatabase
        refresh() if $scope.partial
        $rootScope.$broadcast('changeDatabase', $rootScope.selectedDatabase)

    $scope.changeServer = () ->
        $rootScope.selectedServer = $scope.selectedServer
        $scope.selectedDatabase = null
        #$scope.pageCache?.data?.server = $scope.selectedServer

        getDatabaseList().then () ->
            refresh() if $scope.partial

    ## Misc methods
    formatDateFromNow = $scope.formatDateFromNow = (datetime) ->
        return unless datetime
        moment(datetime.replace('Z', '')).fromNow()

    formatDateTime = $scope.formatDateTime = (datetime) ->
        return unless datetime
        moment(datetime.replace('Z', '')).format('YYYY-MM-DD HH:mm:ss')

    $scope.round = (value, places) ->
        return value if !value
        value.toFixed(places)

    $scope.numberFormat = (value) ->
        return value if !value
        value.toLocaleString()

    $scope.formatSql = (tsql) ->
        formatSql.format(tsql)

    $scope.deArrayify = (data) ->
        data[0]

    $scope.preFormatSprocDatesFromNow = (data) ->
        _.each data, (d) ->
            d.dateFromNow = formatDateFromNow(d.lastExecutionTime)
        data

    $scope.formatProcessGroupDates = (data) ->
        _.each data, (d) ->
            d.latestBatchDate = formatDateTime(d.latestBatchDate)
            d.firstBatchDate = formatDateTime(d.firstBatchDate)
        data

    $scope.formatIndexes = (data) ->
        _.each data, (d) ->
            d.lastUserSeek = formatDateTime(d.lastUserSeek)
            d.lastUserScan = formatDateTime(d.lastUserScan)
            d.lastUserLookup = formatDateTime(d.lastUserLookup)
            d.lastUserUpdate = formatDateTime(d.lastUserUpdate)
        data

    ## Query methods
    query = (template, data={}) ->
        data.server = $rootScope.selectedServer
        $http.post('query', {template: template, data: data})
            .then (res) ->
                return res.data
            .catch (err) ->
                console.error err

    fetchQuery = (template, data, processFn) ->
        data.database = $rootScope.selectedDatabase.name
        query(template, data).then (data) ->
            $scope.partial = template
            $scope.infos = processFn(data[0])
            setNavData($scope.infos)

    # main data function called from the page links
    loadData = $scope.loadData = (template, data, processFn=identity) ->
        $scope.partial = 'loading'
        obj =
            template: template
            data: data
            processFn: processFn
        $scope.navigate(obj) # set navigation
        fetchQuery(template, data, processFn)

    # post processing functions
    # these are specific functions used as a post query filtering or processing function
    # reuse of these would be great, but the idea is that each query may have its own function
    identity = _.identity


    # This should probably be factored out into own service
    $scope.findBlockers = (data) ->
        # find spids that are not blocked but are blocking others
        spids = {}
        blocked = []
        blockers = []
        clear = []

        _.each data, (d) ->
            d.dateFromNow = formatDateFromNow(d.lastBatch) # hack this in here
            if d.blocked != 0
                blockers.push(d.blocked)
                blocked.push(d.spid)
            else
                clear.push(d.spid)

        heads = _.intersection(clear, blockers)
        _.each data, (d) ->
            if _.contains heads, d.spid
                d.isBlockingHead = 1
        data


    # initialization
    #####################
    $scope.nav =
        page: 'main'
    $scope.this = {}
    navStack = [{template: 'main', data: null, processFn: null}]

    $rootScope.configuredServers = config.availableServers.split(",")
    $rootScope.selectedServer = $scope.configuredServers[0]

    getDatabaseList()

    # always get server stats on start
    query('serverStats').then (data) ->
        $scope.server =
            name: data[0][0].SERVERNAME
            version: data[1][0].VERSION
            lastRestart: moment((data[2][0].sqlserver_start_time)?.replace('Z', '')).format('YYYY/M/D HH:m:s')

