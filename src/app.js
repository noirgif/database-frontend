var express = require('express'); // Web Framework
var url = require('url');
var app = express();
var mysql = require('mysql'); // Mysql client

var database = 'bank';
// Connection string parameters.
var connection = mysql.createConnection({
    user: 'root',
    password: '',
    server: 'localhost',
    database: database
});

// Start server and listen on http://localhost:8081/
var server = app.listen(8081, function () {
    var host = server.address().address
    var port = server.address().port

    console.log("app listening at http://%s:%s", host, port)
});

var sqlerrorhandler = function (req, res, err) {
    res.status(400).end(err.sqlMessage);
}

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/(:table/show)?$', function (req, res) {
    res.sendFile('public/db.html', { root: __dirname });
});

app.use('^/public', express.static(__dirname + '/public'));

app.get('^/tables$', function (req, res) {
    var query = connection.query('show tables');
    var rows = [];
    query.on('err', (err) => {
        sqlerrorhandler(req, res, err);
    })
        .on('result', (row, index) => {
            connection.pause();
            rows.push(row["Tables_in_" + database])
            connection.resume();
        })
        .on('end', () => {
            res.end(JSON.stringify(rows));
        });
});

app.get('^/charts$', function (req, res) {
    res.sendFile('public/charts.html', { root: __dirname });
});

app.get('^/:table/get$', function (req, res) {
    var table = decodeURI(req.params.table);
    connection.query('SELECT 1 FROM ?? LIMIT 1;', [table], function (err, results, fields) {
        if (err)
            sqlerrorhandler(req, res, err);
        else
            connection.query('SELECT * FROM ??', [table], function (err, results, fields) {
                if (err)
                    sqlerrorhandler(req, res, err);
                else
                    res.end(JSON.stringify(results)); // Result in JSON format
            });
    });
});

app.post('^/:table/get$', function (req, res) {
    var table = decodeURI(req.params.table);
    connection.query('SELECT 1 FROM ?? LIMIT 1;', [table], function (err, results, fields) {
        if (err)
            sqlerrorhandler(req, res, err);
        else
        {
            var condition = [];
            var conditionstring = '';
            var querystring = 'SELECT * from ??';
            for (key in req.body)
            {
                condition.push(connection.escapeId(key) + '=' + connection.escape(req.body[key]));
            }
            conditionstring = condition.join(' AND ')
            if (conditionstring)
                querystring = querystring + ' WHERE ' + conditionstring;
            connection.query(querystring, [table], function (err, results, fields) {
                if (err)
                    sqlerrorhandler(req, res, err);
                else
                    res.end(JSON.stringify(results)); // Result in JSON format
            });
        }
    });
});

app.get('^/:table/getcolumns$', function (req, res) {
    var table = decodeURI(req.params.table);
    connection.query('SHOW COLUMNS FROM ??', [table], function (err, results, fields) {
        if (err)
            sqlerrorhandler(req, res, err);
        else
            res.end(JSON.stringify(results.map(row => row.Field))); // Result in JSON format
    });
});

app.post('^/:table/insert$', function (req, res) {
    var table = decodeURI(req.params.table);
    connection.query('INSERT INTO ?? SET ?', [table, req.body], function (err, result, fields) {
        if (err) {
            sqlerrorhandler(req, res, err);
        }
        else {
            console.log(result.affectedRows + " record(s) updated");
            res.send(result.affectedRows + " record(s) affected");
        }
    });
});

app.get('^/:table/delete$', function (req, res) {
    var id = req.query.id;
    var table = decodeURI(req.params.table);
    connection.query('DELETE FROM ?? WHERE ID = ?', [table, id], function (err, result, fields) {
        if (err) {
            sqlerrorhandler(req, res, err);
        }
        else {
            console.log(result.affectedRows + " record(s) updated");
            res.send(result.affectedRows + " record(s) affected");
        }
    });
});

app.post('^/:table/update$', function (req, res) {
    var id = req.query.id;
    var table = decodeURI(req.params.table);
    connection.query('UPDATE ?? SET ? WHERE ID = ?', [table, req.body, id], function (err, result, fields) {
        if (err) {
            sqlerrorhandler(req, res, err);
        }
        else {
            console.log(result.affectedRows + " record(s) updated");
            res.send(result.affectedRows + " record(s) affected");
        }
    });
});
