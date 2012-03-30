var util   = require('util'),
    sqlite = require('sqlite-fts');

var originDb = new sqlite.Database(),
    resultDb = new sqlite.Database();



originDb.open('metroFrequencias.sqlite3', function(){
  resultDb.open('metro-out.sqlite3', function(){
  
    createTables(function(){
      copyStations(function(){
        copyStationLocations(function(){
          copyTimes(function(){
          
          });
        });
      });
    });
    
  });
});

var directions = ["ETXEBARRI", "SANTURTZI", "PLENTZIA", "LARRABASTERRA", "BIDEZABAL", "URDULIZ", "BASAURI", "SANINAZIO"];


/*
 *  Create table estaments
 */

var createTablesQuery = 
  "create table stations ( \
    id integer(4) primary key, \
    name varchar(30),  \
    joints text);\n"+
    
  "create table station_locations ( \
    station_id integer(4), \
    lat number, \
    lng number, \
    location_name varchar(30), \
    FOREIGN KEY(station_id) REFERENCES stations(id));"+
  
  "create table times ( \
    station_id integer(4), \
    direction integer(4), \
    daytype integer(1), \
    time integer(4), \
    FOREIGN KEY(station_id) REFERENCES stations(id));"+

  "create table connections ( \
    station_1_id integer(4), \
    station_2_id integer(4), \
    gap integer(2));"+

  "create index station_name_index on stations(name);"+
  "create index station_location_id_index on station_locations(station_id);"+
  "create index times_station_index on times(station_id);"+
  "create index times_daytype_index on times(daytype);"+
  "create index times_time_index on times(time);";

function createTables(callback) {
  console.log("> Creating tables...");
  resultDb.executeScript(createTablesQuery, function(err){
    if (err)
      console.log("! " + err);
    callback();
  });
}

/*
 *  copy stations
 */

// Dictionary containing tableName: station_id
var stationsDictionary = {};
var stationsTables = [];

function copyStations(callback) {
  
  originDb.execute("select * from stations order by name asc", function(err, rows){
    var query = "";
    for (i in rows) {
      station = rows[i];
      stationsDictionary[station._tableName] = station._id;
      stationsTables.push(station._tableName);
      query += "insert into stations values ("+station._id+",'"+station.name+"','"+(station.joints?station.joints:"")+"');\n";
    }
    console.log("> Creating stations...")
    resultDb.executeScript(query, function(err){
      if (err)
        console.log("! " + err);
      
      callback();
    });
  });
}

function copyStationLocations(callback) {
  originDb.execute("select * from stationsexits", function(err, rows){
    var query = "";
    for (i in rows) {
      var exit = rows[i];
      query += "insert into station_locations values ("+exit.actualStation+","+exit.latitude+","+exit.longitude+",'"+(exit.exitName?exit.exitName:"")+"');\n";
    }
    
    console.log("> Creating station exits...");
    
    resultDb.executeScript(query, function(err){
      if (err)
        console.log("! " + err);
      
      callback();
    });
  });
}

function copyTimes(callback, index) {
  if (index == undefined)
    index = 0;
  
  if (index < stationsTables.length) {
    var stationId = stationsDictionary[stationsTables[index]];
    
    originDb.execute("select * from "+stationsTables[index], function(err, rows){
      var query = "";
      for (i in rows) {
        var time = rows[i];
        if (stationsDictionary[directions[time.direction]] == undefined) {
          console.log(stationsDictionary)
        }
        
        query += "insert into times values ("+stationId+","+stationsDictionary[directions[time.direction]]+","+time.dayType+","+time.hour+");\n";
      }
      
      console.log("> Creating times for "+stationsTables[index]+"...");
      
      resultDb.executeScript(query, function(err){
        if (err)
          console.log("! " + err);
        
        copyTimes(callback, index + 1);
      });
    });
    
  } else {
    callback();
  }
  
  
}
