const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(express.json());


// Conectar a MongoDB Atlas
mongoose.connect('mongodb+srv://a1122150092:WHEm2kv1SPwKURh3@schoolproyect.nnkdi.mongodb.net/QualityAlertSystem?retryWrites=true&w=majority&appName=SchoolProyect')  //q_alert
  .then(() => console.log('Conectado a MongoDB Atlas'))
  .catch(err => console.log(err));

// Definir el esquema de usuario
const userSchema = new mongoose.Schema({
  employeeNumber: String,
  firstName: String,
  lastName: String,
  password: String,
  role: String,
  area: String,
  email: String,
  createdAt: Date,
  updatedAt: Date
  /*nombre: String,
  email: String,
  password: String,
  numEmpleado: String*/
});

const User = mongoose.model('User', userSchema);

// Ruta para registrar un usuario
app.post('/register', async (req, res) => {
  //const { nombre, email, password, numEmpleado } = req.body;
  //employeeNumber, firstName, lastName, password, role, area, email, createdAt, updatedAt
  const { employeeNumber, firstName, lastName, password, role, area, email, createdAt, updatedAt } = req
  console.log("Recibiendo datos del cliente:", req.body);  // Verifica que los datos lleguen correctamente

  if (!employeeNumber || !firstName || !lastName || !password || !role || !area || !email || !createdAt || !updatedAt) {   //!nombre || !email || !password || !numEmpleado
    return res.status(400).json({ error: 'Todos los campos son obligatorios' });
  }

  try {
    // Hashear la contraseña antes de guardarla
    const salt = await bcrypt.genSalt(10); // Generar un "salt"
    const hashedPassword = await bcrypt.hash(password, salt); // Hashear la contraseña

    // Crear el nuevo usuario con la contraseña hasheada
    const newUser = new User({
      employeeNumber,
      firstName,
      lastName,
      password: hashedPassword,
      role,
      area,
      email,
      createdAt,
      updatedAt

      /*nombre,
      email,
      password: hashedPassword, Guardar la contraseña hasheada
      numEmpleado*/
    });

    await newUser.save();  // Guardar en la base de datos
    res.status(201).json({ message: 'Usuario registrado exitosamente' });
  } catch (error) {
    console.error('Error al registrar usuario:', error);
    res.status(500).json({ error: 'Hubo un error al registrar el usuario' });
  }
});

// Ruta para iniciar sesión
app.post('/login', async (req, res) => {
  const { employeeNumber, password } = req.body;  //const { email, password } = req.body;

  try {
    // Buscar el usuario por su correo o numEmployee
    const user = await User.findOne({ employeeNumber }); //email
    if (!user) {
      return res.status(400).json({ error: 'Usuario no encontrado' });
    }

    // Comparar la contraseña proporcionada con la contraseña hasheada en la base de datos
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Contraseña incorrecta' });
    }

    // Generar un token JWT
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
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`API escuchando en el puerto ${PORT}`);
});

