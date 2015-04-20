app = angular.module("app", [
    'ngRoute', 'ngSanitize'
]).config ($routeProvider) ->
    $routeProvider
        .when("/",
            templateUrl: "templates/main.html"
        ).when("/404",
            templateUrl: "templates/404.html"
        ).otherwise redirectTo: "/404"