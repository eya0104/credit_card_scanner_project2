const CardInfo = require('../models/card_info');
const cardInfoService = require('../services/card_info.service.js');


// Get all card info
const getAllCardInfo = async (req, res) => {
  try {
    const cardInfo = await cardInfoService.getAllCardInfo();
    res.json(cardInfo);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get card info by ID
const getCardInfoById = async (req, res) => {
  try {
    const cardInfo = await cardInfoService.getCardInfoById(req.params.id);
    if (cardInfo) {
      res.json(cardInfo);
    } else {
      res.status(404).json({ message: 'Card info not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Update card info by ID
const updateCardInfoById = async (req, res) => {
  try {
    const updatedCardInfo = await cardInfoService.updateCardInfoById(req.params.id, req.body, { new: true });
    if (updatedCardInfo) {
      res.json(updatedCardInfo);
    } else {
      res.status(404).json({ message: 'Card info not found' });
    }
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Delete card info by ID
const deleteCardInfoById = async (req, res) => {
  try {
    const deletedCardInfo = await cardInfoService.deleteCardInfoById(req.params.id);
    if (deletedCardInfo) {
      res.json({ message: 'Card info deleted successfully' });
    } else {
      res.status(404).json({ message: 'Card info not found' });
    }
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

module.exports = {
  getAllCardInfo,
  getCardInfoById,
  updateCardInfoById,
  deleteCardInfoById
};
