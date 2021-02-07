const bodyParser = require('body-parser');
const http = require('http')
const util = require('util');
const express = require('express')
const app = express();
const constants = require('./config/constants.json')

app.get('',(req,res)=>{
    res.render('',{'title':'param','created':'qamar'})
})

app.listen(3000,()=>{console.log('running server')
})
console.log('Hello')