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

  insertUser(username) {
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

  insertGroup(groupname, cn, dn) {
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

  insertGroupUser(groupid, userid) {
    try {
      return this.pool
        .request()
        .input('GroupID', sql.Int, groupid)
        .input('UserID', sql.Int, userid)
        .execute('ActiveDirectory.InsertGroupUsers');
    }
    catch (error) {
      console.error(error);
    }
  }
  
  insertSubsystem(sourceid, name, data) {
    try {
      return this.pool
        .request()
        .input('SourceID', sql.Int, sourceid)
        .input('name', sql.NVarChar, name)
        .input('JsonData', sql.NVarChar, data)
        .execute('SubSystems.InsertObjects');
    }
    catch (error) {
      console.error(error);
    }
  }
  
  insertSystemLink(ObjectID, GroupID) {
    try {
      return this.pool
        .request()
        .input('ObjectID', sql.Int, ObjectID)
        .input('GroupID', sql.Int, GroupID)
        .execute('Link.InsertObjectRelations');
    }
    catch (error) {
      console.error(error);
    }
  }

  getGroupid(name) {
    try {
      return this.pool
        .request()
        .input('GroupName', sql.NVarChar, name)
        .execute('ActiveDirectory.SelectGroupID');
    }
    catch (error) {
      console.error(error);
    }
  }
}