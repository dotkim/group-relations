const Mssql = require('./mssql');
const db = new Mssql();

const Mongo = require('./mongo');
const mdb = new Mongo();


(async function () {
  try {
    await db.connect();
    let groups = await mdb.getAdGroups();
    groups.forEach((group) => {
      console.log(group.name);
      db.insertGroup(group.name, group.canonicalName, group.distinguishedName);
      group.members.forEach(async (user) => {
        console.log(user);
        db.insertUser(user);
        db.insertGroupUser(group.name, user);
      });
    });
    console.log('Done');
  }
  catch (error) {
    console.error(error);
  }
})();