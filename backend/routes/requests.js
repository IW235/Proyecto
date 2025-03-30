const express = require('express');
const requestController = require('../controllers/requestController');

const router = express.Router();

router.post('/', requestController.createRequest);
router.get('/', requestController.getRequests);
router.put('/:id/approve', requestController.approveRequest);
router.get('/completed', requestController.getCompletedRequests); // Add route for completed requests
router.put('/:id/reject', requestController.rejectRequest);


module.exports = router;
