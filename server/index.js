require('dotenv').config();
const cors = require('cors');
const express = require('express');
const mongoose = require('mongoose');

const app = express();
const mongoString = process.env.DATABASE_URL;

// Use CORS middleware
app.use(cors());
app.use(express.json());

// Connect to the database
async function connectToDatabase() {
  try {
    await mongoose.connect(mongoString, { useNewUrlParser: true, useUnifiedTopology: true });
    console.log('Database Connected');
  } catch (error) {
    console.error('Error connecting to the database:', error);
    process.exit(1);
  }
}

connectToDatabase();

// Add routes here after connecting to the database
const userRoutes = require('./routes/user');
app.use('/api/users', userRoutes);

const cardInfoRoutes = require('./routes/card_info');
app.use('/api/card_info', cardInfoRoutes);

app.listen(3000, () => {
  console.log(`Server Started at ${3000}`);
});
