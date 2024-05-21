const express = require('express');
const {
  getUsers,
  updateUser,
  deleteUser,
  getUserById,
  getUserByEmail,
  signup,
  login,
  getLoggedUser
} = require('../controllers/user');
const verifyToken = require('../middleware/auth');

const router = express.Router();

// Route definitions
router.get('/users', getUsers); // Directly use getUsers from imported controllers

router.route('/')
  .get(getUsers); // Route to get all users

router.route('/email')
  .get(getUserByEmail); // Route to get user by email

router.route('/:_id')
  .get(getUserById) // Route to get user by id
  .delete(deleteUser) // Route to delete user by id
  .put(updateUser); // Route to update user by id

// User registration
router.route('/register').post(signup);

// User login
router.route('/login').post(login);

// Logged-in user profile
router.route('/profile/me').get(verifyToken, getLoggedUser);

module.exports = router;
