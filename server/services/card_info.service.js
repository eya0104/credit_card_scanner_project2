const {deleteCardInfo} = require('../controllers/card_info.js');
const CardInfoModel = require('../models/card_info');


const getAllCardInfo = async () => {
  try {
    const cardInfo = await CardInfo.find();
    return cardInfo;
  } catch (error) {
    throw new Error(error.message);
  }
};

const getCardInfoById = async (id) => {
  try {
    const cardInfo = await CardInfo.findById(id);
    if (cardInfo) {
      return cardInfo;
    } else {
      throw new Error('Card info not found');
    }
  } catch (error) {
    throw new Error(error.message);
  }
};

const updateCardInfoById = async (id, updateData) => {
  try {
    const updatedCardInfo = await CardInfo.findByIdAndUpdate(id, updateData, { new: true });
    if (updatedCardInfo) {
      return updatedCardInfo;
    } else {
      throw new Error('Card info not found');
    }
  } catch (error) {
    throw new Error(error.message);
  }
};

const deleteCardInfoById = async (id) => {
  try {
    const deletedCardInfo = await CardInfo.findByIdAndDelete(id);
    if (deletedCardInfo) {
      return { message: 'Card info deleted successfully' };
    } else {
      throw new Error('Card info not found');
    }
  } catch (error) {
    throw new Error(error.message);
  }
};

module.exports = {
  getAllCardInfo,
  getCardInfoById,
  updateCardInfoById,
  deleteCardInfoById
};