const mongoose = require('mongoose');

class {
  constructor() {
    this.conn = mongoose.connect('mongodb://localhost:27017')
  }
}