const User = require('../models/User');
const db = require('../models/User').db;

exports.createRevision = async (req, res) => {
    try {
        const { operator, inspector, area, date } = req.body;
        console.log('=== INICIO DE CREACIÓN DE REVISIÓN ===');
        console.log('Datos recibidos:', JSON.stringify(req.body, null, 2));

        // Validar que los datos requeridos estén presentes
        if (!operator || !inspector || !area || !date) {
            console.log('Datos incompletos:', { operator, inspector, area, date });
            return res.status(400).json({ message: 'Faltan datos requeridos' });
        }

        // Validar estructura de datos
        if (!Array.isArray(operator) || !Array.isArray(inspector)) {
            console.log('Estructura de datos incorrecta');
            return res.status(400).json({ message: 'Estructura de datos incorrecta' });
        }

        // Verificar si ya existe una revisión para esta combinación
        const existingRevision = await db.collection('revisions').findOne({
            'operator.0.employeeNumber': operator[0].employeeNumber,
            'inspector.0.employeeNumber': inspector[0].employeeNumber,
            area: area,
            date: date
        });

        if (existingRevision) {
            console.log('Revisión duplicada encontrada:', existingRevision);
            return res.status(409).json({ message: 'Ya existe una revisión con estos datos' });
        }

        // Obtener los datos completos del inspector
        console.log('Buscando inspector con número:', inspector[0].employeeNumber);
        const inspectorData = await User.findOne({ employeeNumber: inspector[0].employeeNumber });
        
        if (!inspectorData) {
            console.log('Inspector no encontrado:', inspector[0].employeeNumber);
            return res.status(404).json({ message: 'Inspector no encontrado' });
        }

        console.log('Datos del inspector encontrado:', inspectorData);

        // Crear el documento de revisión con estructura consistente
        const revision = {
            operator: [{
                employeeNumber: operator[0].employeeNumber,
                firstName: operator[0].firstName,
                lastName: operator[0].lastName
            }],
            inspector: [{
                employeeNumber: inspectorData.employeeNumber,
                firstName: inspectorData.firstName,
                lastName: inspectorData.lastName
            }],
            area: area,
            date: date
        };

        console.log('Documento a guardar:', JSON.stringify(revision, null, 2));

        // Guardar en la colección revisions
        const result = await db.collection('revisions').insertOne(revision);
        console.log('Resultado de la inserción:', result);

        console.log('=== FIN DE CREACIÓN DE REVISIÓN ===');
        res.status(201).json({
            message: 'Revisión guardada exitosamente',
            revision: revision
        });
    } catch (error) {
        console.error('Error al guardar la revisión:', error);
        res.status(500).json({ message: 'Error al guardar la revisión' });
    }
}; 