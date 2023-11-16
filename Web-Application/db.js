const mysql = require('mysql');
require('dotenv').config();
// console.log(process.env)
const connection = mysql.createConnection({
    host     : process.env.RDS_HOSTNAME,
    user     : process.env.RDS_USERNAME,
    password : process.env.RDS_PASSWORD,
    port     : process.env.RDS_PORT    
});

connection.connect(function(err) {
    // if (err) throw err;
    if (err) {
        console.error('Database connection failed: ' + err.stack);
        return;
      }
    console.log("Connected!");

    connection.query('CREATE DATABASE IF NOT EXISTS lifi;');
    connection.query('USE lifi;');
    connection.query('CREATE TABLE IF NOT EXISTS users(id int NOT NULL AUTO_INCREMENT, username varchar(30), email varchar(255), age int, PRIMARY KEY(id));', function(error, result, fields) {
        console.log(result);
    });


    // connection.end();
});

module.exports = connection;