const express = require('express');
const app = express();

const connection = require('./db');

// The status endpoint
app.get('/status', (req, res) => res.send({status: "I'm alive!"}));

// The data endpoint, that takes in 3 parameters (username, email and age)
app.post('/data', (req, res) => {
    if (req.query.username && req.query.email && req.query.age) {
        console.log('Request received');
        connection.connect(function(err) {
            connection.query(`INSERT INTO lifi.users (username, email, age) VALUES ('${req.query.username}', '${req.query.email}', '${req.query.age}')`, function(err, result, fields) {
                if (err) res.send(err);
                if (result) res.send({username: req.query.username, email: req.query.email, age: req.query.age});
                if (fields) console.log(fields);
            });
        });
    } else {
        console.log('Missing a parameter!');
    }
});

// The users endpoint to fetch data from our rds database
app.get('/users', (req, res) => {
    connection.connect(function(err) {
        connection.query(`SELECT * FROM lifi.users`, function(err, result, fields) {
            if (err) res.send(err);
            if (result) res.send(result);
        });
    });
});

// launch our server on port 3001.
const server = app.listen(3001, () => {
  console.log('listening on port %s...', server.address().port);
});