
app.controller 'main', ($rootScope, $scope, $http, $timeout) ->

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

    $scope.formatDateFromNow = (datetime) ->
        moment(datetime.replace('Z', '')).fromNow()

    query = (template, data) ->
        $http.post('/query', {template: template, data: data})
            .then (res) ->
                return res.data
            .catch (err) ->
                console.error err

    fetchQuery = (template, data, processFn) ->
        data.database = $scope.selectedDatabase.name
        query(template, data).then (data) ->
            $scope.partial = template
            $scope.infos = processFn(data)
            resultStack.push $scope.infos

    # initialize
    $scope.nav =
        page: 'main'
    $scope.this = {}
    navStack = ['main']
    resultStack = []

    query('allDatabases').then (data) -> 
        $scope.databases = data
        $scope.selectedDatabase = _.first _.filter data, (d) -> d.name == 'master'

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
    $scope.refresh = () ->
        $scope.partial = 'loading'
        fetchQuery($scope.pageCache.template, $scope.pageCache.data, $scope.pageCache.processFn)

    # post processing functions
    identity = _.identity

    $scope.deArrayify = (data) ->
        data[0]
