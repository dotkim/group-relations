const Mongo = require('./mongo');
const db = new Mongo();

(async function() {
  let g = await db.getAdGroups();
  console.log(g);
})();