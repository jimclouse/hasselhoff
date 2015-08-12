app = angular.module("app", [
    'ngRoute', 'ngSanitize'
]).config ($routeProvider) ->
    $routeProvider
        .when("/",
            templateUrl: "templates/main.html"
        ).when("/dictionary/:database?/:tableId?",
        	templateUrl: "templates/dictionary.html"
        ).when("/404",
            templateUrl: "templates/404.html"
        ).otherwise redirectTo: "/404"