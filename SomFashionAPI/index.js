var express = require('express');
var app = express();
var bodyParser = require('body-parser');
const url = require('url');
const querystring = require('querystring');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.use(function (req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    res.header ("Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE");
    next();
  });
app.use(express.static(__dirname));
app.get('/Mail', function (req, res) {
    var api = require('./Controller/SomFashionController.js');
    api.getMail(req, res);
})
app.get('/AddUser', function (req, res) {
    var api = require('./Controller/SomFashionController.js');
    api.getAddUser(req, res);
})
app.get('/SignIn', function (req, res) {
    var api = require('./Controller/SomFashionController.js');
    api.getLogin(req, res);
})
app.get('/UpdateUser', function (req, res) {
    var api = require('./Controller/SomFashionController.js');
    api.getUpdateUser(req, res);
})
app.get('/LatestProduct', function (req, res) {
    var api = require('./Controller/SomFashionController.js');
    api.getLatestProduct(req, res);
})
app.get('/CategoryProduct', function (req, res) {
    var api = require('./Controller/SomFashionController.js');
    api.getCategoryProduct(req, res);
})
app.get('/ProductID', function (req, res) {
    var api = require('./Controller/SomFashionController.js');
    api.getProductID(req, res);
})
app.get('/MenCategory', function (req, res) {
    var api = require('./Controller/SomFashionController.js');
    api.getMenCat(req, res);
})
app.get('/WomenCategory', function (req, res) {
    var api = require('./Controller/SomFashionController.js');
    api.getWomenCat(req, res);
})
app.get('/GetProductPrice', function (req, res) {
    var api = require('./Controller/SomFashionController.js');
    api.getGetProductPrice(req, res);
})
app.get('/Image', function(req, res) {

  var queryObject = url.parse(req.url,true).query;
  var imageFile=__dirname+"/img/product/"+ queryObject.filename;
  //console.log(imageFile);
  res.sendFile(imageFile);
});
app.get('/GetSize', function (req, res) {
    var api = require('./Controller/SomFashionController.js');
    api.getGetSize(req, res);
})
  var server = app.listen(8082, function () {
    var host = server.address().addresscd
    var port = server.address().port
    console.log("Listening at http://%s:%s", host, port)
 })

