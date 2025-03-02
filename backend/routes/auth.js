const express = require('express');
const User = require('../models/User');
const jwt = require('jsonwebtoken');
const router = express.Router();

// ruta de inicio de sesion
router.post('/login', async (req, res) => {
  try {
    const { employeeNumber, password } = req.body;   ///email

    // Buscar al usuario por número de empleado
    const user = await User.findOne({ employeeNumber });  //email
    if (!user) {
      return res.status(400).json({ message: 'Número de empleado o contraseña incorrectos' });
    }

    // Comparar contraseñas
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Número de empleado o contraseña incorrectos' });
    }

    // Crear y enviar el token
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
      expiresIn: '1h'
    });

    // Devolver el token y los datos del usuario 
    res.json({
      token,
      user: {
        employeeNumber: user.employeeNumber,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        area: user.area,
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error del servidor' });
  }
});

module.exports = router;
