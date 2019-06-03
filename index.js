const Mongo = require('./mongo');
const db = new Mongo();
const fs = require('fs');

(async function () {
  let groups = await db.groupsWithZero();
  let objArr = [];
  await groups.forEach(async (gobj) => {
    let relations = await db.getGroupObj(gobj.name);
    gobj['relations'] = relations;
    return gobj;
  });

  console.log(objArr);
  console.log('Done');
})();