const db = require('../models/User').db; // Obtener la instancia de la base de datos
const { ObjectId } = require('mongodb');

exports.createRequest = async (req, res) => {
  try {
    console.log('=== INICIO DE CREACIÓN DE SOLICITUD ===');
    const requestData = req.body;
    console.log('Datos recibidos:', JSON.stringify(requestData, null, 2));

    if (!requestData) {
      console.log('Datos de solicitud inválidos');
      return res.status(400).json({ error: 'Datos de solicitud inválidos' });
    }

    // Crear el documento de solicitud con la estructura correcta
    const request = {
      operatorId: requestData.operatorId,
      operatorName: requestData.operatorName,
      area: requestData.area,
      piece: requestData.piece,
      complement: requestData.complement,
      date: new Date()
    };

    console.log('Documento a guardar:', JSON.stringify(request, null, 2));

    // Guardar en la colección requests
    const result = await db.collection('requests').insertOne(request);
    console.log('Resultado de la inserción:', result);

    console.log('=== FIN DE CREACIÓN DE SOLICITUD ===');
    res.status(201).json({ 
      message: 'Solicitud recibida correctamente',
      request: request
    });
  } catch (error) {
    console.error('Error al guardar la solicitud:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
};

exports.getRequests = async (req, res) => {
  try {
    const requests = await db.collection('requests').find().toArray();
    res.status(200).json(requests);
  } catch (error) {
    console.error('Error al obtener las solicitudes:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
};

exports.getCompletedRequests = async (req, res) => {
    try {
        const completedRequests = await db.collection('revisions').find().toArray();
        res.status(200).json(completedRequests);
    } catch (error) {
        console.error('Error al obtener las solicitudes completadas:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
};

exports.approveRequest = async (req, res) => {

  const requestId = req.params.id;

  try {
    await db.collection('requests').updateOne(
      { _id: new ObjectId(requestId) },
      { $set: { status: 'Aprobada' } }
    );
    res.status(200).json({ message: 'Solicitud aprobada correctamente' });
  } catch (error) {
    console.error('Error al aprobar la solicitud:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
};

exports.rejectRequest = async (req, res) => {
  const requestId = req.params.id;

  try {
    await db.collection('requests').updateOne(
      { _id: new ObjectId(requestId) },
      { $set: { status: 'Rechazada' } }
    );
    res.status(200).json({ message: 'Solicitud rechazada correctamente' });
  } catch (error) {
    console.error('Error al rechazar la solicitud:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
};
