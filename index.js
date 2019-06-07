const Migrate = require('./migrate');
const mig = new Migrate();

(async () => {
  let data = await mig.subsystems();
  console.log('data:', data);
})();