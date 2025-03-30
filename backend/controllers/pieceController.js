const db = require('../models/User').db; // Obtener la instancia de la base de datos

exports.getPiecesByArea = async (req, res) => {
  const area = req.query.area;

  if (!area) {
    return res.status(400).json({ error: 'El parámetro "area" es requerido' });
  }

  try {
    const areaData = await db.collection('areas').findOne({ name: area });

    if (!areaData) {
      return res.status(404).json({ error: 'Área no encontrada' });
    }

    res.json({ pieces: areaData.pieces });
  } catch (error) {
    console.error('Error al obtener las piezas:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
};