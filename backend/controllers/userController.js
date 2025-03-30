const User = require('../models/User');
const Revision = require('../models/revisions'); // Import the Revision model
const bcrypt = require('bcryptjs');

exports.createUser = async (req, res) => {
    try {
      const user = new User(req.body);
      const newUser = await user.save();
      res.status(201).json(newUser);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  };
  
exports.getUsers = async (req, res) => {
    try {
      const users = await User.find();
      res.json(users);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };
  
exports.getUsersByRole = async (req, res) => {
    const { role } = req.params;
    try {
      const usersByRole = await User.find({ role });
      res.json(usersByRole);
    } catch (err) {
      res.status(500).json({ error: 'Error al obtener los usuarios por rol' });
    }
  };
  
exports.updateUser = async (req, res) => {
    try {
      const user = await User.findByIdAndUpdate(req.params.id, req.body, { new: true });
      if (!user) {
        return res.status(404).json({ message: 'Usuario no encontrado' });
      }
      res.json(user);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  };
  
exports.deleteUser = async (req, res) => {
    try {
      const user = await User.findByIdAndDelete(req.params.id);
      if (!user) {
        return res.status(404).json({ message: 'Usuario no encontrado' });
      }
      res.json({ message: 'Usuario eliminado correctamente' });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };

async function comparePassword(inputPassword, storedPassword) {
    try {
        console.log('Comparando contraseñas...');
        const isMatch = await bcrypt.compare(inputPassword, storedPassword);
        console.log('Resultado de la comparación:', isMatch);
        return isMatch;
    } catch (error) {
        console.error('Error al comparar contraseñas:', error);
        throw error;
    }
}

exports.getInspectorName = async (req, res) => {
    const { area } = req.query;
    console.log('Área solicitada:', area); // Log para depuración

    try {
        // Primero, verificar si hay inspectores en la base de datos
        const allInspectors = await User.find({ role: 'Inspector' });
        console.log('Todos los inspectores en la base de datos:', allInspectors);

        // Buscar el inspector específico
        const inspector = await User.findOne({ 
            area: area, 
            role: 'Inspector' 
        });
        console.log('Inspector encontrado para área:', area, inspector);

        if (!inspector) {
            console.log('No se encontró inspector para el área:', area);
            return res.status(404).json({ 
                message: 'Inspector not found',
                details: `No se encontró un inspector para el área: ${area}`
            });
        }

        const response = {
            name: `${inspector.firstName} ${inspector.lastName}`,
        };
        console.log('Respuesta a enviar:', response);
        res.status(200).json(response);
    } catch (error) {
        console.error('Error fetching inspector:', error);
        res.status(500).json({ 
            message: 'Server error',
            error: error.message 
        });
    }
};

exports.completeInspection = async (req, res) => {
    const { inspectorNumber, password, piece, complement } = req.body;

    console.log('Verificando inspector:', inspectorNumber);
    console.log('Pieza:', piece);
    console.log('Complemento:', complement);

    try {
        const inspector = await User.findOne({ employeeNumber: inspectorNumber, role: 'Inspector' });
        console.log('Inspector encontrado:', inspector ? 'Sí' : 'No');

        if (!inspector) {
            console.log('Inspector no encontrado');
            return res.status(400).json({ 
                message: 'Inspector not found',
                details: 'No se encontró un inspector con ese número de empleado'
            });
        }

        console.log('Contraseña proporcionada:', password);
        console.log('Contraseña almacenada:', inspector.password);
        const isMatch = await comparePassword(password, inspector.password);

        console.log('Contraseña correcta:', isMatch);

        if (!isMatch) {
            console.log('Contraseña incorrecta');
            return res.status(400).json({ 
                message: 'Incorrect password',
                details: 'La contraseña proporcionada es incorrecta'
            });
        }

        // Solo enviar respuesta de éxito, no crear revisión aquí
        res.status(200).json({ 
            message: 'Inspection completed',
            details: 'La inspección ha sido marcada como completada'
        });
    } catch (error) {
        console.error('Error completing inspection:', error);
        res.status(500).json({ 
            message: 'Server error',
            details: error.message
        });
    }
};
