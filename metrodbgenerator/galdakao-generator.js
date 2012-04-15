var util   = require('util'),
    sqlite = require('sqlite-fts');

var db = new sqlite.Database();

function generateTimesInserts(from, to, step, dt, origin, dest){
  var script = "";
  for (var i = from; i <= to; i += step) {
    script += 'insert into times values ('+origin+', '+dest+', '+dt+', '+i+');\n';
  }
  return script;
}

db.open('metro-times.sqlite3', function(){
  var script = "";
  
  /*
   *  Galdakao - Ariz
   */
  
  // Dias normales
  for (var dt in [0, 1, 2]) {
    script += generateTimesInserts(5*60+30, 5*60+59, 30,dt, 100, 7);
    script += generateTimesInserts(6*60, 22*60+30, 10,dt, 100, 7);
  }
  
  // Domingos
  script += generateTimesInserts(6*60+45, 8*60+5, 20, 3, 100, 7);
  script += generateTimesInserts(8*60+25, 22*60+35, 10, 3, 100, 7);
  
  // Viernes noche
  script += generateTimesInserts(22*60+50, 23*60+59, 30, 1, 100, 7);
  script += generateTimesInserts(0*60+20, 1*60+20, 30, 2, 100, 7);
  
  // Sábado noche
  script += generateTimesInserts(22*60+50, 23*60+59, 30, 2, 100, 7);
  script += generateTimesInserts(0*60+20, 6*60+20, 30, 3, 100, 7);
  
  /*
   *  Ariz - Galdakao
   */
  
  // Dias normales
  for (var dt in [0, 1, 2]) {
    script += generateTimesInserts(6*60+30, 23*60+0, 10,dt, 7, 100);
  }
  
  // Domingos
  script += generateTimesInserts(6*60+45, 8*60+05, 20, 3, 7, 100);
  script += generateTimesInserts(8*60+25, 23*60+05, 10, 3, 7, 100);
  
  // Viernes noche
  script += generateTimesInserts(23*60+15, 23*60+59, 30, 1, 7, 100);
  script += generateTimesInserts(0*60+15, 1*60+45, 30, 2, 7, 100);
  
  // Sábado noche
  script += generateTimesInserts(23*60+15, 23*60+59, 30, 2, 7, 100);
  script += generateTimesInserts(0*60+15, 6*60+45, 30, 3, 7, 100);
  
  
  console.log(script);
  db.executeScript(script, function(err){
  
  });
});
