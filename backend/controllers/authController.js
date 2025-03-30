const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

exports.register = async (req, res) => {
  const { employeeNumber, firstName, lastName, password, role, area, email } = req.body;

  if (!employeeNumber || !firstName || !lastName || !password || !role || !area || !email) {
    return res.status(400).json({ error: 'Todos los campos son obligatorios' });
  }

  try {
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = new User({
      employeeNumber,
      firstName,
      lastName,
      password: hashedPassword,
      role,
      area,
      email,
    });

    await newUser.save();
    res.status(201).json({ message: 'Usuario registrado exitosamente' });
  } catch (error) {
    console.error('Error al registrar usuario:', error);
    res.status(500).json({ error: 'Hubo un error al registrar el usuario' });
  }
};

exports.login = async (req, res) => {
  const { employeeNumber, password } = req.body;

  try {
    const user = await User.findOne({ employeeNumber });
    if (!user) {
      return res.status(400).json({ error: 'Usuario no encontrado' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Contraseña incorrecta' });
    }

    const token = jwt.sign({ userId: user._id }, 'secretKey', { expiresIn: '1h' });
    res.status(200).json({
      token,
      user: {
        employeeNumber: user.employeeNumber,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        area: user.area,
      },
    });
  } catch (err) {
    console.error('Error en el inicio de sesión:', err);
    res.status(500).json({ error: 'Error en el servidor' });
  }
};