require('dotenv').config();
const sql = require('mssql');

const config = {
  user: process.env.MSSQL_USER,
  password: process.env.MSSQL_PASSWORD,
  server: process.env.MSSQL_SERVER, // You can use 'localhost\\instance' to connect to named instance
  database: process.env.MSSQL_DATABASE,
  port: Number(process.env.MSSQL_PORT)
};

module.exports = class {
  async connect() {
    this.pool = await sql.connect(config);
  }

  async insertUser(username) {
    return this.pool
      .request()
      .input('username', sql.NVarChar, username)
      .execute('ActiveDirectory.InsertUsers');
  }
}