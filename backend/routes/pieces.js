const express = require('express');
const User = require('../models/Area');
const pieceController = require('../controllers/pieceController');
const router = express.Router();

// Endpoint para obtener las piezas y complementos de un área
/*router.get('/pieces', async (req, res) => {
  const { area } = req.query;

  try {
    // Buscar el área por su nombre
    const areaData = await Area.findOne({ name: area });
    if (!areaData) {
      console.log('Area not found:', area); // Add this line
      return res.status(404).json({ message: 'Área no encontrada' });
    }

    // Devolver las piezas y complementos
    res.status(200).json(areaData.pieces);
  } catch (err) {
    console.error('Error al obtener las piezas:', err);
    res.status(500).json({ message: 'Error del servidor' });
  }
});

module.exports = router;*/

router.get('/', pieceController.getPiecesByArea);

module.exports = router;