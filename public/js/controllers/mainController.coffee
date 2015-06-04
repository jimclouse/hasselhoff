
app.controller 'main', ($rootScope, $scope, $http, $timeout, formatSql) ->

    $scope.navigateBack = () ->
        navStack.pop()
        resultStack.pop()
        p = navStack.slice(-1)[0]
        if p in ['main', 'system', 'maintenance']
            $scope.partial = null
            $scope.infos = null
            $scope.pageCahce = null
        else 
            $scope.partial = p
            $scope.infos = resultStack.slice(-1)[0]
        $scope.nav.page = p

    $scope.navigate = (page) ->
        navStack.push(page)
        $scope.nav.page = page

    $scope.goHome = () ->
        navStack = []
        resultStack = []
        $scope.nav.page = 'main'
        $scope.partial = null
        $scope.pageCahce = null

    $scope.changeDatabase = () ->
        refresh() if $scope.partial

    formatDateFromNow = $scope.formatDateFromNow = (datetime) ->
        moment(datetime.replace('Z', '')).fromNow()

    formatDateTime = $scope.formatDateTime = (datetime) ->
        moment(datetime.replace('Z', '')).format('YYYY-MM-DD HH:mm:ss')

    $scope.formatSql = (tsql) ->
        formatSql.format(tsql)

    query = (template, data) ->
        $http.post('query', {template: template, data: data})
            .then (res) ->
                return res.data
            .catch (err) ->
                console.error err

    fetchQuery = (template, data, processFn) ->
        data.database = $scope.selectedDatabase.name
        query(template, data).then (data) ->
            $scope.partial = template
            $scope.infos = processFn(data[0])
            resultStack.push $scope.infos

    # main data function called from the page links
    loadData = $scope.loadData = (template, data, processFn=identity) ->
        $scope.partial = 'loading'
        $scope.navigate(template) # set navigation
        $scope.pageCache =
            template: template
            data: data
            processFn: processFn
        fetchQuery(template, data, processFn)

    # use the stored pageCache info to re-run the current query
    refresh = $scope.refresh = () ->
        $scope.partial = 'loading'
        fetchQuery($scope.pageCache.template, $scope.pageCache.data, $scope.pageCache.processFn)

    # post processing functions
    # these are specific functions used as a post query filtering or processing function
    # reuse of these would be great, but the idea is that each query may have its own function
    identity = _.identity

    $scope.deArrayify = (data) ->
        data[0]

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

    $scope.preFormatSprocDatesFromNow = (data) ->
        _.each data, (d) ->
            d.dateFromNow = formatDateFromNow(d.lastExecutionTime)
        data

    $scope.formatProcessGroupDates = (data) ->
        _.each data, (d) ->
            d.latestBatchDate = formatDateTime(d.latestBatchDate)
            d.firstBatchDate = formatDateTime(d.firstBatchDate)
        data

    # initialization
    #####################
    $scope.nav =
        page: 'main'
    $scope.this = {}
    navStack = ['main']
    resultStack = []

    query('allDatabases').then (data) -> 
        $scope.databases = data[0]
        $scope.selectedDatabase = _.first _.filter data[0], (d) -> d.name == 'master'

    query('serverStats').then (data) ->
        $scope.server = 
            name: data[0][0].SERVERNAME
            version: data[1][0].VERSION
            lastRestart: moment((data[2][0].sqlserver_start_time)?.replace('Z', '')).format('YYYY/M/D HH:m:s')
            
