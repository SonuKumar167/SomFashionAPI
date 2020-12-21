const md5 = require('./encrypt.js');    
var nodemailer = require('nodemailer');
var sql = require('mysql');

var config = {
    host: 'localhost',
    database: 'ecommerce',
    user: 'root',
    password: '',
    port: 3306,
    timezone: 'ist'
};
exports.loadMail = function (req, res) {

    var Otp = Math.floor(100000 + Math.random() * 900000);
    var email = req.query.email;
    var con = new sql.createConnection(config);

    con.connect(function (err) {
        if (err) throw err;


        con.query("SELECT id,email,firstname,lastname,img from user where email='" + email +"'", function (err, result, fields) {

            if (err) throw err;
            //cons
            //console.log(result.length);
            if (result.length > 0) {
                res.setHeader('Content-Type', 'application/json');
                res.status(200).send({ "status": 0, "msg": "User Already Exist. Please Login" });
            }
            else {
                var transporter = nodemailer.createTransport({
                    host: "smtpout.secureserver.net",
                    port: 587,
                    service: 'Godaddy',
                    auth: {
                        user: 'info@sharememento.com',
                        pass: 'sharem2020##'
                    }
                });

                var mailOptions = {
                    from: 'info@sharememento.com',
                    to: email,
                    subject: 'Authentication Code',
                    html: '<b>Welcome to ShareMemento<b><hr/><i>Your one time authentication code is ' + Otp +'</i><hr/><p>Will be valid for 5 Minutes.</p>'
                };

                transporter.sendMail(mailOptions, function (error, info) {
                    if (error) {
                        console.log(error);
                    } else {
                        console.log('Email sent: ' + info.response);

                        res.setHeader('Content-Type', 'application/json');
                        res.status(200).send({ "status": 1, "msg": "sent","Otp": Otp });

                    }
                });
            }

        });
    });
    return res;
    }
exports.loadAddUser = function (req, res) {
    var con = new sql.createConnection(config);
    con.connect(function (err) {
        if (err) throw err;
        var email = req.query.email;
        var pass = md5.calcMD5(req.query.pass);
        con.query("select id from user where email='"+email+"'",function(err1,result1,field1){
           
            if (err1) throw err;
            if(result1.length >0){    
              res.setHeader('Content-Type', 'application/json');
              res.status(200).send({"status":0, "msg":"User Already exist"});
            }
            else{         
            con.query("insert into user(email,password,img) values('" + email + "','" + pass + "','user.png'); ", function (err, result, fields) {

              if (err) throw err;
              }); 
            }
            con.query("select * from user where email='" + email + "' and password='" + pass + "'; ", function (err, result, fields) {

                if (err) throw err;
                res.setHeader('Content-Type', 'application/json');
                res.status(200).send({"status":1, "msg":"User Added","data":result});
            });
        });
    });
    return res;
}
exports.loadUpdateUser = function (req, res) {
    var con = new sql.createConnection(config);
    con.connect(function (err) {
        if (err) throw err;
        var fname = req.query.fname;
        var lname = req.query.lname;
        var id = req.query.id;
        var img = req.query.img;
        con.query("Update user set firstname = '" + fname + "', lastname = '" + lname + "', img = '"+img+"' where id = '" + id + "'; ", function (err, result, fields) {

            if (err) throw err;
            //cons
            //console.log(result);
            res.setHeader('Content-Type', 'application/json');
            res.status(200).send({ "status": 1, "msg": "User Updated Successfully" });
            console.log({ "status": 1, "msg": "User Updated Successfully" });
            //res=JSON.stringify({ message: 'test!' });
        });
        con.end();
    });
    return res;
}
exports.loadLogin = function (req, res) {
    var con = new sql.createConnection(config);
    con.connect(function (err) {
        if (err) throw err;
        var email = req.query.email;
        var pass = req.query.pass;
        con.query("SELECT `user_id`, `email`, `first_name` from user_info where email = '" + email + "' and password = '" + pass + "' ; ", function (err, result, fields) {

            if (err) throw err;
            //cons
            
            if (result.length > 0) {
                //console.log({ "status": 1, "msg": "Login Successfull", "data": result });
                res.setHeader('Content-Type', 'application/json');
                res.status(200).send({ "status": 1, "msg": "Login Successfull", "data": result });
            }
            else {
                console.log({ "status": 0, "msg": "Invalid user or wrong password" });
                res.setHeader('Content-Type', 'application/json');
                res.status(200).send({ "status": 0, "msg": "Invalid user or wrong password" });
            }

            //res=JSON.stringify({ message: 'test!' });
        });
        con.end();
    });
    return res;
}
exports.loadLatestProduct = function (req, res) {
    var con = new sql.createConnection(config);
    con.connect(function (err) {
        if (err) throw err;
            con.query("SELECT distinct p.product_code,p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand order by p.product_id desc limit 25,10 ", function (err, result, fields) {
                if (err) throw err;
                res.setHeader('Content-Type', 'application/json');
                res.status(200).send({"status":1, "msg":"Data Available","data":result});
            });
    });
    return res;
}
exports.loadProductID = function (req, res) {
	var pid = req.query.id;
    var con = new sql.createConnection(config);
    con.connect(function (err) {
        if (err) throw err;
            con.query("SELECT p.product_id, p.product_title, p.product_price,p.product_size,p.product_qty, p.product_desc, p.product_image_front,p.product_image_back,p.product_image_side, p.product_keywords, c.cat_title, c.cat_id, b.brand_id, b.brand_title FROM products p JOIN categories c ON c.cat_id = p.product_cat JOIN brands b ON b.brand_id = p.product_brand where p.product_id='"+pid+"' order by p.product_id desc  limit 1", function (err, result, fields) {
                if (err) throw err;
				if(result.length > 0){
                  res.setHeader('Content-Type', 'application/json');
                  res.status(200).send({"status":1, "msg":"Data Available","data":result});
				}
				else{
                  res.setHeader('Content-Type', 'application/json');
                  res.status(200).send({"status":0, "msg":"No Record Found"});
				}
            });
    });
    return res;
}
exports.loadGetSize = function (req, res) {
	var pid = req.query.pid;
    var con = new sql.createConnection(config);
    con.connect(function (err) {
        if (err) throw err;
            con.query("select product_size from product_size where product_id='"+pid+"'", function (err, result, fields) {
                if (err) throw err;
				if(result.length > 0){
                  res.setHeader('Content-Type', 'application/json');
                  res.status(200).send({"status":1, "msg":"Data Available","data":result});
				}
				else{
                  res.setHeader('Content-Type', 'application/json');
                  res.status(200).send({"status":0, "msg":"No Record Found"});
				}
            });
    });
    return res;
}
exports.loadGetProductPrice = function (req, res) {
	var pid = req.query.pid;
	var size = req.query.size;
    var con = new sql.createConnection(config);
    con.connect(function (err) {
        if (err) throw err;
            con.query("select product_price, product_qty from product_size where product_id='"+pid+"' and product_size='"+size+"'", function (err, result, fields) {
                if (err) throw err;
				if(result.length > 0){
                  res.setHeader('Content-Type', 'application/json');
                  res.status(200).send({"status":1, "msg":"Data Available","data":result});
				}
				else{
                  res.setHeader('Content-Type', 'application/json');
                  res.status(200).send({"status":0, "msg":"No Record Found"});
				}
            });
    });
    return res;
}
exports.loadCategoryProduct = function (req, res) {
	//var pid = req.query.id;
    var con = new sql.createConnection(config);
    con.connect(function (err) {
        if (err) throw err;
            con.query("call `SP_ProductFilter`('','','','','','','','');", function (err, result, fields) {
                if (err) throw err;
				if(result.length > 0){
                  res.setHeader('Content-Type', 'application/json');
                  res.status(200).send({"status":1, "msg":"Data Available","data":result});
				}
				else{
                  res.setHeader('Content-Type', 'application/json');
                  res.status(200).send({"status":0, "msg":"No Record Found"});
				}
            });
    });
    return res;
}
exports.loadMenCat = function (req, res) {
	var pid = req.query.id;
    var con = new sql.createConnection(config);
    con.connect(function (err) {
        if (err) throw err;
            con.query("SELECT C.cat_id,C.brand_id,C.cat_title,C.gender,C.wear,P.Count from ( SELECT * from categories where gender='Men') C LEFT join ( select count(*) as Count,product_cat from products GROUP by product_cat) P ON C.cat_id = P.product_cat ;", function (err, result, fields) {
                if (err) throw err;
				if(result.length > 0){
                  res.setHeader('Content-Type', 'application/json');
                  res.status(200).send({"status":1, "msg":"Data Available","data":result});
				}
				else{
                  res.setHeader('Content-Type', 'application/json');
                  res.status(200).send({"status":0, "msg":"No Record Found"});
				}
            });
    });
    return res;
}
exports.loadWomenCat = function (req, res) {
	var pid = req.query.id;
    var con = new sql.createConnection(config);
    con.connect(function (err) {
        if (err) throw err;
            con.query("SELECT C.cat_id,C.brand_id,C.cat_title,C.gender,C.wear,P.Count from ( SELECT * from categories where gender='Women') C,( select count(*) as Count,product_cat from products GROUP by product_cat) P where C.cat_id = P.product_cat ;", function (err, result, fields) {
                if (err) throw err;
				if(result.length > 0){
                  res.setHeader('Content-Type', 'application/json');
                  res.status(200).send({"status":1, "msg":"Data Available","data":result});
				}
				else{
                  res.setHeader('Content-Type', 'application/json');
                  res.status(200).send({"status":0, "msg":"No Record Found"});
				}
            });
    });
    return res;
}