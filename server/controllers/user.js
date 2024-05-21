const UserServices = require('../services/user.service.js');
const User = require ("../models/user");
const jwt = require ('jsonwebtoken');
const argon2 = require ('argon2');


//User login
 async function login(req, res) {
  try {
    const { email, password } = req.body;
    const user = await UserServices.getUserByEmail({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    } // 404: Resource not found

    const isPasswordValid = await argon2.verify(user.password, password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Invalid credentials' });
    } // 401: User not authenticated

     const token = await UserServices.generateAccessToken({ id: user._id, email: user.email }, process.env.JWT_SECRET, '1h');
        res.json({ message: 'Login successful', token });
      } catch (err) {
        res.status(500).json({ message: 'Error logging in', error: err.message });
      }
    }


//User signup
 async function signup(req, res) {
  try {
    const { username, email, password } = req.body;
    const hashedPassword = await argon2.hash(password, {type: argon2.argon2i});
    const user = await UserServices.registerUser({ username, email, password: hashedPassword });
    res.status(201).json({ message: 'User registered successfully', user });
  } // 201: Created
  catch (err) {
    res.status(500).json({ message: 'Error registering user', error: err.message });
  } // 500: Server errors
}

//Get loggedIn user
 function getLoggedUser(req, res) {
  res.json({ user: req.user });
}


//Get user by email
 async function getUserByEmail(req, res) {
   try {
     const user = await UserServices.getUserByEmail(req.params.email);
     if (user) {
       res.status(200).json(user);
     } else {
       res.status(404).json({ error: 'User not found' });
     }
   } catch (err) {
     res.status(500).json({ error: err.message });
   }
 }

//Get user by Id
 async function getUserById(req, res) {
   try {
     const user = await UserServices.getUserById(req.params.id);
     if (user) {
       res.status(200).json(user);
     } else {
       res.status(404).json({ error: 'User not found' });
     }
   } catch (err) {
     res.status(500).json({ error: err.message });
   }
 }


//Delete user by Id
 async function deleteUser(req, res) {
   try {
     const user = await UserServices.deleteUser(req.params.id);
     if (user) {
       res.status(200).json({ message: 'User successfully deleted' });
     } else {
       res.status(404).json({ error: 'User not found' });
     }
   } catch (err) {
     res.status(500).json({ error: err.message });
   }
 }

//Get all users
 async function getUsers(req, res) {
   try {
     const users = await UserServices.getUsers();
     res.status(200).json(users);
   } catch (err) {
     res.status(500).json({ error: err.message });
   }
 }


//Update user by Id
 async function updateUser(req, res) {
   try {
     const user = await UserServices.updateUser(req.params.id, req.body);
     if (user) {
       res.status(200).json(user);
     } else {
       res.status(404).json({ error: 'User not found' });
     }
   } catch (err) {
     res.status(400).json({ error: err.message });
   }
 }


module.exports = {
 login,
 signup,
 getLoggedUser,
 getUserByEmail,
 getUserById,
 deleteUser,
 getUsers,
 updateUser,
};
