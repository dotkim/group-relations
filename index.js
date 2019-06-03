const Mssql = require('./mssql');
const db = new Mssql();

(async function () {
  await db.connect();
  let data = await db.insertUser('kimner');
  console.log(data);
})();