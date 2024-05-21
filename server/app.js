const express = require("express");
const bodyParser = require("body-parser");
const userRoute = require("./routes/user.js");
const cardInfoRoute = require('./routes/card_info.js');
const app = express();

app.use(bodyParser.json());

// Use the user routes
app.use("/api/user", userRoute);

// Use the card info routes
app.use("/api/card_info", cardInfoRoute);

module.exports = app;
