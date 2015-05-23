
app.controller 'main', ($rootScope, $scope, $http, $timeout) ->

    $scope.navigateBack = () ->
        navStack.pop()
        p = navStack.slice(-1)[0]
        if p in ['main', 'system', 'maintenance']
            $scope.partial = null
        else 
            $scope.partial = p
        $scope.nav.page = p

    $scope.navigate = (page) ->
        navStack.push(page)
        $scope.nav.page = page

    $scope.goHome = () ->
        navStack = []
        $scope.nav.page = 'main'
        $scope.partial = null

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
            $scope.partial = template.replace('get_', '')
            $scope.infos = processFn(data)

    # initialize
    $scope.nav =
        page: 'main'

    $scope.this = {}

    navStack = ['main']

    query('get_databases').then (data) -> 
        $scope.databases = data
        $scope.selectedDatabase = _.first _.filter data, (d) -> d.name == 'master'

    $scope.loadData = (template, data, processFn=identity) ->
        $scope.partial = 'loading'
        $scope.navigate(template.replace('get_', '')) # set navigation
        fetchQuery(template, data, processFn)

    # post processing functions
    identity = _.identity

    $scope.deArrayify = (data) ->
        console.log data
        data[0]
