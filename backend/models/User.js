const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  employeeNumber: {
    type: String,
    required: true,
    unique: true
  }, 
  firstName:{
    type:String,
    required:true
  }, 
  lastName:{
    type:String,
    required:true
  },
  password: {
    type: String,
    required: true,
  },
  role:{
    type:String,
    required:true
  },
  area:{
    type:String,
    required:true
  },
  email:{
    type:String,
    required:true
  },
  createdAt: {
    type: Date,
  },
  updatedAt:{
    type:Date
  }
 
/*
employeeNumber, firstName, lastName, password, role, area, email, createdAt, updatedAt

  
  */

  /*nombre: { type: String, required: true },   Aquí añades el campo "nombre"
  email: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true
  },
  numEmpleado: { type: String, required: true }   Añades "numEmpleado"*/
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 10);
  }
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
