const mongoose = require('mongoose');

const complementSchema = new mongoose.Schema({
  complementId: mongoose.Schema.Types.ObjectId,
  complementName: String,
});

const pieceSchema = new mongoose.Schema({
  pieceId: mongoose.Schema.Types.ObjectId,
  pieceName: String,
  complements: [complementSchema],
});

const areaSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
  },
  pieces: [pieceSchema],
});

module.exports = mongoose.model('Area', areaSchema);