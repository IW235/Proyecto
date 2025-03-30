const express = require('express');
const User = require('../models/User');
const userController = require('../controllers/userController');

const requestController = require('../controllers/requestController'); // Import requestController

const router = express.Router();

router.get('/requests/completed', requestController.getCompletedRequests); // Add route for completed requests


router.post('/complete-inspection', userController.completeInspection);

router.get('/inspector', userController.getInspectorName);

router.get('/', userController.getUsers);

router.get('/role/:role', userController.getUsersByRole);

router.put('/:id', userController.updateUser);

router.delete('/:id', userController.deleteUser);


module.exports = router;
