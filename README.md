# Database Frontend

The frontend for a database, allowing editing, and things.

## Structure

1. Javascript send queries with GET requests, and process the results in the webpage

2. Node.js server check the requests, and turn it into sql queries, return the results of SQL queries

## Requirements

* Each table must have a auto increment field `ID` as its primary key(or at least unique not null)

## RESTful API

1. queries
    * `/{table name}/get` : query all table contents
    * `/{table name}/insert` : insert a new line into the db, the values of the columns is in the POST data, separated by EOL
    * `/{table name}/delete?id={id}` : delete a line from db
    * `/{table name}/update?id={id}` : update a single row with POST request, in the POST request, each value of the updated columns takes up a line

2. 