var util   = require('util'),
    sqlite = require('sqlite-fts');

var db = new sqlite.Database(),
    resultDb = new sqlite.Database();



db.open('tranvia-times.sqlite3', function(){
  db.execute('select * from times where daytype = 0', function (err, rows) {
    for (var row in rows) {
      var time = rows[row];
      db.execute('insert into times values ('+time.station_id+','+time.direction+','+1+','+time.time+')', function () {
        
    })
    }
  })
});
