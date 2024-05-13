const express = require('express');
const app = express();
const port = 3000;

//endpoint de test
app.get('/',(req,res) => {
 res.send('API is working !');
});

//start the server
app.listen(port,() => {
 console.log('server is working on port ${port}');
});