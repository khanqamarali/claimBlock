const express = require('express')
const log4js = require('log4js');
const logger = log4js.getLogger('CLAIMBlock');
const app = express()
app.use(express.json())
const port = 3000
const registerUser = require('./src/registerUser.js')
app.get('/', (req, res) => {
  res.send('Hello World!')
})
app.post('/register', async function (req, res) {
  debugger
  var username = req.body.username;
  var orgName = req.body.orgName;
  logger.debug('End point : /users');
  logger.debug('User name : ' + username);
  logger.debug('Org name  : ' + orgName);
  if (!username) {
      res.json(getErrorMessage('\'username\''));
      return;
  }
  if (!orgName) {
      res.json(getErrorMessage('\'orgName\''));
      return;
   }

  let response = await registerUser.registerAndGerSecret(username, orgName);

  logger.debug('-- returned from registering the username %s for organization %s', username, orgName);
  if (response && typeof response !== 'string') {
      logger.debug('Successfully registered the username %s for organization %s', username, orgName);
      //response.token = token;
      res.json(response);
  } else {
      logger.debug('Failed to register the username %s for organization %s with::%s', username, orgName, response);
      res.json({ success: false, message: response });
  }

});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)})