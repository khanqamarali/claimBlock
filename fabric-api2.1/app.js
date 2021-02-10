const express = require('express')
const app = express()
app.use(express.json())
const port = 3000
const registerUser = require('./src/registerUser.js')
app.get('/', (req, res) => {
  res.send('Hello World!')
})
app.post('/users', async function (req, res) {
  var username = req.body.username
  var orgName = req.body.orgName
  console.log(username)
  console.log(orgName) 
 // result = registerUser.getRegisteredUser(username,orgName,true)
  res.json('hello') 
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)})