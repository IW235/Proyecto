/*const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('./models/User'); 
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Obtener la instancia de la base de datos
const db = mongoose.connection;

// Middleware para parsear datos de formularios
app.use(express.urlencoded({ extended: true }));

// Conectar a MongoDB Atlas
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('Conectado a MongoDB Atlas'))
  .catch(err => console.log(err));

/* Definir el esquema de usuario
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
  numEmpleado: String
});

const User = mongoose.model('User', userSchema);
//cerrar aquiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii

// Ruta para registrar un usuario
app.post('/register', async (req, res) => {
  //const { nombre, email, password, numEmpleado } = req.body;
  //employeeNumber, firstName, lastName, password, role, area, email, createdAt, updatedAt
  const { employeeNumber, firstName, lastName, password, role, area, email, createdAt, updatedAt } = req.body;
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
      numEmpleado// cerrarrr aquiiiiiii
    });
    

    await newUser.save();  // Guardar en la base de datos
    res.status(201).json({ message: 'Usuario registrado exitosamente' });
  } catch (error) {
    console.error('Error al registrar usuario:', error);
    res.status(500).json({ error: 'Hubo un error al registrar el usuario' });
  }
});


// Ruta para iniciar sesión
app.post('/api/auth/login', async (req, res) => {
  const { employeeNumber, password } = req.body;  //const { email, password } = req.body;

  try {
    // Buscar el usuario por su correo o numEmployee
    const user = await User.findOne({ employeeNumber }); //email
    if (!user) {
      return res.status(400).json({ error: 'User not found' });
    }

    // Comparar la contraseña proporcionada con la contraseña hasheada en la base de datos
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Incorrect password' });
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
// Endpoints
// 1. Crear un usuario (POST)
app.post('/api/users', async (req, res) => {
  try {
    const user = new User(req.body);
    const newUser = await user.save();
    res.status(201).json(newUser);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// 2. Obtener todos los usuarios (GET)
app.get('/api/users', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

/**
 * Obtener usuarios por rol (GET /users/role/:role)
 
app.get('/users/role/:role', async (req, res) => {
  const { role } = req.params;
  try {
    const usersByRole = await User.find({ role });
    res.json(usersByRole);
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener los usuarios por rol' });
  }
});

// 3. Actualizar un usuario (PUT)
app.put('/api/users/:id', async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    res.json(user);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// 4. Eliminar un usuario (DELETE)
app.delete('/api/users/:id', async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    res.json({ message: 'Usuario eliminado correctamente' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});
// Ruta para obtener las piezas según el área
app.get('/api/pieces', async (req, res) => {
  const area = req.query.area;

  if (!area) {
    return res.status(400).json({ error: 'El parámetro "area" es requerido' });
  }

  try {
    // Buscar el área en la colección "areas"
    const areaData = await db.collection('areas').findOne({ name: area });

    if (!areaData) {
      return res.status(404).json({ error: 'Área no encontrada' });
    }

    // Devolver la lista de piezas
    res.json({ pieces: areaData.pieces });
  } catch (error) {
    console.error('Error al obtener las piezas:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Ruta para enviar solicitudes
app.post('/api/requests', async (req, res) => {
  const requestData = req.body;

  if (!requestData) {
    return res.status(400).json({ error: 'Datos de solicitud inválidos' });
  }

  try {
    // Guardar la solicitud en la colección "requests"
    await db.collection('requests').insertOne(requestData);

    // Responder con éxito
    res.status(201).json({ message: 'Solicitud recibida correctamente' });
  } catch (error) {
    console.error('Error al guardar la solicitud:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Ruta para obtener todas las solicitudes
app.get('/api/requests', async (req, res) => {
  try {
    // Obtener todas las solicitudes de la colección "requests"
    const requests = await db.collection('requests').find().toArray();

    // Responder con la lista de solicitudes
    res.status(200).json(requests);
  } catch (error) {
    console.error('Error al obtener las solicitudes:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});
// Ruta para aprobar una solicitud
app.put('/api/requests/:id/approve', async (req, res) => {
  const requestId = req.params.id;

  try {
    // Actualizar el estado de la solicitud a "Aprobada"
    await db.collection('requests').updateOne(
      { _id: new ObjectId(requestId) },
      { $set: { status: 'Aprobada' } }
    );

    res.status(200).json({ message: 'Solicitud aprobada correctamente' });
  } catch (error) {
    console.error('Error al aprobar la solicitud:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});


app.listen(process.env.PORT || 5000, () => { 
  console.log(`API escuchando en el puerto ${process.env.PORT || 5000}`);
});*/
// Importar la aplicación Express configurada en app.js
const http = require('http');
const socketIo = require('socket.io');
const app = require('./index');

const server = http.createServer(app);
const io = socketIo(server);

io.on('connection', (socket) => {
  console.log('Nuevo cliente conectado:', socket.id);

  // Escuchar eventos de solicitudes
  socket.on('sendRequest', (data) => {
    console.log('Solicitud recibida:', data);

    // Notificar a los inspectores
    io.emit('newRequest', data);
  });

  // Escuchar eventos de notificaciones
  socket.on('sendNotification', (data) => {
    console.log('Notificación recibida:', data);

    // Enviar la notificación al operador correspondiente
    io.to(data.operatorId).emit('notification', data.message);
  });

  socket.on('disconnect', () => {
    console.log('Cliente desconectado:', socket.id);
  });
});
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Servidor escuchando en el puerto ${PORT}`);
});