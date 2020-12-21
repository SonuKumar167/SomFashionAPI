var somFashionModel = require('../Model/SomFashionModel.js');
 
exports.getMail = function(req, res) {
    //res.writeHead(200, {'Content-Type': 'text/json'});
    return ( somFashionModel.loadMail(req, res));
}
exports.getAddUser = function (req, res) {
    //res.writeHead(200, {'Content-Type': 'text/json'});
    return (somFashionModel.loadAddUser(req, res));
}
exports.getLogin = function (req, res) {
    //res.writeHead(200, {'Content-Type': 'text/json'});
    return (somFashionModel.loadLogin(req, res));
}
exports.getUpdateUser = function (req, res) {
    //res.writeHead(200, {'Content-Type': 'text/json'});
    return (somFashionModel.loadUpdateUser(req, res));
}
exports.getLatestProduct = function (req, res) {
    //res.writeHead(200, {'Content-Type': 'text/json'});
    return (somFashionModel.loadLatestProduct(req, res));
}
exports.getCategoryProduct = function (req, res) {
    //res.writeHead(200, {'Content-Type': 'text/json'});
    return (somFashionModel.loadCategoryProduct(req, res));
}
exports.getProductID = function (req, res) {
    //res.writeHead(200, {'Content-Type': 'text/json'});
    return (somFashionModel.loadProductID(req, res));
}
exports.getMenCat = function (req, res) {
    //res.writeHead(200, {'Content-Type': 'text/json'});
    return (somFashionModel.loadMenCat(req, res));
}
exports.getWomenCat = function (req, res) {
    //res.writeHead(200, {'Content-Type': 'text/json'});
    return (somFashionModel.loadWomenCat(req, res));
}
exports.getGetProductPrice = function (req, res) {
    //res.writeHead(200, {'Content-Type': 'text/json'});
    return (somFashionModel.loadGetProductPrice(req, res));
}
exports.getGetSize = function (req, res) {
    //res.writeHead(200, {'Content-Type': 'text/json'});
    return (somFashionModel.loadGetSize(req, res));
}
