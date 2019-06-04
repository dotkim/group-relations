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
    try {
      this.pool = await sql.connect(config);
    }
    catch (error) {
      console.error(error);
    }
  }

  async insertUser(username) {
    try {
      return this.pool
        .request()
        .input('username', sql.NVarChar, username)
        .execute('ActiveDirectory.InsertUser');
    }
    catch (error) {
      console.error(error);
    }
  }

  async insertGroup(groupname, cn, dn) {
    try {
      return this.pool
        .request()
        .input('GroupName', sql.NVarChar, groupname)
        .input('CN', sql.NVarChar, cn)
        .input('DN', sql.NVarChar, dn)
        .execute('ActiveDirectory.InsertGroup');
    }
    catch (error) {
      console.error(error);
    }
  }

  async insertGroupUser(group, user) {
    try {
      let gid = await this.pool.request().query(`SELECT GroupID FROM ActiveDirectory.Groups WHERE GroupName = '${group}'`);
      let uid = await this.pool.request().query(`SELECT UserID FROM ActiveDirectory.Users WHERE Username = '${user}'`);
      return this.pool
        .request()
        .input('GroupID', sql.Int, gid)
        .input('UserID', sql.Int, uid)
        .execute('ActiveDirectory.InsertGroupUser');
    }
    catch (error) {
      console.error(error);
    }
  }
}