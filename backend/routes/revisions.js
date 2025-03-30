const express = require('express');
const router = express.Router();
const revisionController = require('../controllers/revisionController');

router.post('/', revisionController.createRevision);

module.exports = router; 