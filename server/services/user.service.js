const UserModel = require("../models/user");
const jwt = require('jsonwebtoken');

class UserServices{

//registre a new user

  static async registerUser({username,email,password}) {
   try {

       console.log('Registering user with email:', email);
           const createUser = new UserModel({ username, email, password});
           return await createUser.save();
         } catch (err) {
           console.error('Error registering user:', err);
           throw err;
   }
  }

//Get user by email
  static async getUserByEmail(email) {
   try {
    return await UserModel.findOne({email});
   } catch (err) {
          console.error('Error fetching user by email:', err);
          throw err;
   }
  }

//check if user exists by email
  static async checkUser(email) {
   try {
    return await UserModel.findOne({email});
   }catch (err) {
          console.error('Error checking user by email:', err);
          throw err;
   }
  }


  // Generate JWT access token
  static async generateAccessToken(tokenData, JWTSecret_key, JWT_EXPIRE) {
    try {
      return jwt.sign(tokenData, JWTSecret_key, { expiresIn: JWT_EXPIRE });
    } catch (err) {
      console.error('Error generating access token:', err);
      throw err;
    }
  }

  // Get all users
    static async getUsers() {
      try {
        return await UserModel.find();
      } catch (err) {
        console.error('Error fetching all users:', err);
        throw err;
      }
    }


}

module.exports = UserServices;