const Mssql = require('./mssql');
const db = new Mssql();

const Mongo = require('./mongo');
const mdb = new Mongo();

module.exports = class {
  async groupUsers() {
    try {
      await db.connect();
      let groups = await mdb.getAdGroups();
      groups.forEach(async (group) => {
        let groupdata = await db.insertGroup(group.name, group.canonicalName, group.distinguishedName);
        group.members.forEach(async (user) => {
          let userdata = await db.insertUser(user);
          db.insertGroupUser(groupdata.recordset[0].GroupID, userdata.recordset[0].UserID);
        });
      });
      return { status: 1 };
    }
    catch (error) {
      console.error(error);
      return { status: 0 };
    }
  }

  async subsystems() {
    try {
      await db.connect();

      let sources = {
        eadmin  : 1,
        ace     : 2,
        ivanti  : 3
      };

      let objects = await mdb.getGroupObj();

      objects.forEach(async (obj) => {
        let src = obj.src.toLowerCase();
        let sourceid = sources[src];
        let newobj = await db.insertSubsystem(sourceid, obj.name, JSON.stringify(obj.data, 0, 0));
        let groups = obj.data.groups;
        let objectid = newobj.recordset[0].ObjectID;

        groups.forEach(async (group) => {
          let groupobj = await db.getGroupid(group);
          if (groupobj.recordset[0]) {
            let groupid = groupobj.recordset[0].GroupID;
            db.insertSystemLink(objectid, groupid);
          }
        });
      });
      return { status: 1 };
    }
    catch (error) {
      console.error(error);
      return { status: 0 };
    }
  }
}