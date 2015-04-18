app.controller 'main', ($rootScope, $scope, $http, $timeout) ->

    $scope.navigateBack = () ->
        navStack.pop()
        p = navStack.slice(-1)[0]
        $scope.partial = null if p in ['main', 'system', 'maintenance']
        $scope.nav.page = p

    $scope.navigate = (page) ->
        navStack.push(page)
        $scope.nav.page = page

    $scope.formatDateFromNow = (datetime) ->
        moment(datetime.replace('Z', '')).fromNow()

    query = (template) ->
        $http.post('/query', {template: template, database: 'glglive'})
            .then (res) ->
                return res.data
            .catch (err) ->
                console.error err

    fetchQuery = (template) ->
        query(template).then (data) ->            
            $scope.infos = data    
            $scope.partial = template.replace('get_', '')

    # initialize
    $scope.nav =
        page: 'main'

    $scope.this = {}

    navStack = ['main']

    query('get_databases').then (data) -> 
        $scope.databases = data
        $scope.selectedDatabase = _.first _.filter data, (d) -> d.name == 'master'

    $scope.loadData = (template) ->
        $scope.navigate(template) # set navigation
        fetchQuery(template)

