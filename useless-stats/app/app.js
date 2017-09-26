'use strict';

// Define statsApp
var statsApp = angular.module('statsApp',['datatables','ngRoute']);

statsApp.run(function(DTDefaultOptions) {
   DTDefaultOptions.setDisplayLength(25);
});

statsApp.config(function ($routeProvider, $locationProvider) {
        // configure the routing rules here
        
	$routeProvider.when('/', {
            templateUrl: '/index.html',
            controller: 'HomeController'
        });


	$routeProvider.when('/dbHome', {
            templateUrl: '/dbHome.html',
            controller: 'StatsListController'
        });

        $routeProvider.when('/sysHome', {
            templateUrl: '/sysHome.html',
            controller: 'SysStatsController'
        });


        $routeProvider.when('/ext-stats/:dbName', {
            templateUrl: '/:dbName',
            controller: 'ExtStatsController'
        });

        // enable HTML5mode to disable hashbang urls
        //$locationProvider.html5Mode(true);
        $locationProvider.html5Mode({
          enabled: true,
          requireBase: false
         });
      });


statsApp.controller('StatsListController', function StatsListController($scope, $http) {
  $http.get('https://got.uc.edu:3000/stats')
  .success(function(data, status, headers, config) {
     $scope.databases = data;
  })
  .error(function(error, status, headers, config) {
     console.log(status);
     console.log("Error occured");
  });
});

statsApp.controller('SysStatsController', function SysStatsController($scope, $http) {
  console.log("hi");
  $http.get('https://got.uc.edu:3000/sysStatsHome')
  .success(function(data, status, headers, config) {
     $scope.machines = data;
  })
  .error(function(error, status, headers, config) {
     console.log(status);
     console.log("Error occured");
  });
});


statsApp.controller('ExtStatsController', function ExtStatsController($scope, $http, $routeParams, $location) {
  var databaseName = $location.search().dbName;
  $scope.params = $routeParams;
  $http.get('https://got.uc.edu:3000/dbCurrConfig/' + databaseName)
  .success(function(data, status, headers, config) {
     $scope.dbparameters = data;
  })
  .error(function(error, status, headers, config) {
     console.log(status);
     console.log("Error occured");
  });
  //Try to pull the stats too
    $http.get('https://got.uc.edu:3000/extstats/' + databaseName)
    .success(function(data, status, headers, config) {
       $scope.databases = data;
    })
  .error(function(error, status, headers, config) {
     console.log(status);
     console.log("Error occured");
  });
  

});


statsApp.controller('ExtVMStatsController', function ExtStatsController($scope, $http, $routeParams, $location) {
  var vmName = $location.search().vmName;
  $scope.params = $routeParams;
  $http.get('https://got.uc.edu:3000/vmCurrConfig/' + vmName)
  .success(function(data, status, headers, config) {
     $scope.vmstats = data;
  })
  .error(function(error, status, headers, config) {
     console.log(status);
     console.log("Error occured");
  });

  $scope.params = $routeParams;
  $http.get('https://got.uc.edu:3000/vmNmap/' + vmName)
  .success(function(data, status, headers, config) {
     $scope.vmNmap = data;
  })
  .error(function(error, status, headers, config) {
     console.log(status);
     console.log("Error occured");
  });
});



function ChartController($scope, $http, $routeParams, $location) {
  var databaseName = $location.search().dbName;
  $scope.params = $routeParams;
    $http.get('https://got.uc.edu:3000/extstats/' + databaseName)
    .success(function(data, status, headers, config) {
       $scope.databases = data;
    })
  .error(function(error, status, headers, config) {
     console.log(status);
     console.log("Error occured");
  });
};
