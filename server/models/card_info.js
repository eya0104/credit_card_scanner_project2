const mongoose = require('mongoose');

const cardInfoSchema = new mongoose.Schema({
  cardNumber: {
    type: String,
    required: true,
    trim: true
  },
  expirationDate: {
    type: Date,
    required: true
  },
  type: {
    type: String,
    required: true
  },
  cardHolderName: {
    type: String,
    required: true,
    trim: true
  }

} ,
 {timestamps:true});

// Create a Mongoose model based on the schema
const CardInfo = mongoose.model('CardInfo', cardInfoSchema);

// Export the model
module.exports = CardInfo;
