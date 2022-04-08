var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

const session = require('express-session');
const https = require('https');
const fs = require('fs');

const index = require('./routes/index');
const users = require('./routes/userlogin');
const userlogin = require('./routes/userlogin');
const userhome = require('./routes/userhome');
const profile = require('./routes/profile');
const logout = require('./routes/logout');
const debug = require('./routes/debug');
const page = require('./routes/page');
const loginchoice = require('./routes/loginchoice');
const esign = require('./routes/esign');

var app = express();

// dotenv is used to read properties from .env file
const dotenv = require('dotenv');

// load contents of .env into process.env
dotenv.config();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: true
}));

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({
  extended: false
}));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use((req, res, next) => {

  if (!req.session.authenticated) {
    // Check for BA Header and asserted user id

    const auth = {
      login: process.env.IAG_BA_USER_ID,
      password: process.env.IAG_BA_USER_PW
    }

    // parse login and password from headers
    const b64auth = (req.headers.authorization || '').split(' ')[1] || ''
    const [_login, password] = new Buffer.from(b64auth, 'base64').toString().split(':')

    // Verify login and password are set and correct
    // if (login && password && login === auth.login && password === auth.password && req.headers.iv_user) {

    // Check if password correct and iv-user header received
    if (password && password === auth.password && req.headers['iv-user']) {

      console.log("IAG Authenticated.  Asserted User: " + req.headers['iv-user']);

      // Mark session authenticated
      req.session.authenticated = true


     var attributes = ["clientip","acr","email","family_name","given_name","mobile_number","groupids",
                       "id_token","realmName","tenantId","uid"]

      // Populate user in session
      req.session.user = {
        "id": req.headers['uid'],
        "userName": req.headers['iv-user'],
        "name": req.headers['displayname'],
      };

      for (attr of attributes) {
        req.session.user[attr] = req.headers[attr.toLowerCase()];
      }
    }
  }
  res.set('Cache-Control','no-store');
  return next()
})

app.use('/', index);
app.use('/users', users);
app.use('/userlogin', userlogin);
app.use('/userhome', userhome);
app.use('/profile', profile);
app.use('/logout', logout);
app.use('/debug', debug);
app.use('/page', page);
app.use('/loginchoice',loginchoice);
app.use('/esign',esign);

// catch 404 and forward to error handler
app.use(function(_req, _res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});


// listen for requests
https.createServer({
    key: fs.readFileSync('./demoapp.key.pem'),
    cert: fs.readFileSync('./demoapp.cert.pem')
  }, app)
  .listen(process.env.LOCAL_SSL_PORT, function() {
    console.log('Your SSL app is listening on port ' + process.env.LOCAL_SSL_PORT);
  });

module.exports = app;
