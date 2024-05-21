const express = require('express');
const router = express.Router();
const cardInfoController = require('../controllers/card_info');




// Route to get all card info
router.get('/get', async (req, res) => {
  try {
    await cardInfoController.getAllCardInfo(req, res);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route to get card info by ID
router.get('/getOne/:id', async (req, res) => {
  try {
    await cardInfoController.getCardInfoById(req, res);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route to update card info by ID
router.patch('/update/:id', async (req, res) => {
  try {
    await cardInfoController.updateCardInfoById(req, res);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route to delete card info by ID
router.delete('/delete/:id', async (req, res) => {
  try {
    await cardInfoController.deleteCardInfoById(req, res);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
