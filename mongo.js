require('dotenv').config();
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const adSchema = new Schema({
  name: String,
  canonicalName: String,
  distinguishedName: String,
  members: Array
});

const groupSchema = new Schema({
  name: String,
  src: String,
  data: Object
});

module.exports = class {
  constructor() {
    this.conn = mongoose.connect(
      process.env.MONGOOSE_MONGO, {
        useNewUrlParser: true,
        useCreateIndex: true,                 // use this to remove the warning: DeprecationWarning: collection.ensureIndex is deprecated. Use createIndexes instead.
        user: process.env.MONGOOSE_USERNAME,
        pass: process.env.MONGOOSE_PASSWORD,
        dbName: process.env.MONGOOSE_DBNAME
      },
      function (err) {
        if (err) console.error('Failed to connect to mongo', err);    // this might be changed to do some better errorhandling later...
      }
    );

    this.ad = mongoose.model('ad', adSchema);
    this.groups = mongoose.model('group', groupSchema);

  }

  async getAdGroups() {
    return this.ad.find();
  }

  async groupsWithZero() {
    return this.ad
      .find()
      .where('members')
      .size(0);
  }
}