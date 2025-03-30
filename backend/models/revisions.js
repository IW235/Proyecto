const mongoose = require('mongoose');

const revisionSchema = new mongoose.Schema({
  operatorId: {
    type: String,
    required: true,
  },
  operator: [
    {
      employeeNumber: {
        type: String,
        required: true,
      },
      firstName: {
        type: String,
        required: true,
      },
      lastName: {
        type: String,
        required: true,
      },
    },
  ],
  inspector: [
    {
      employeeNumber: {
        type: String,
        required: true,
      },
      firstName: {
        type: String,
        required: true,
      },
      lastName: {
        type: String,
        required: true,
      },
    },
  ],
  area: {
    type: String,
    required: true,
  },
  date: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Revision', revisionSchema);
