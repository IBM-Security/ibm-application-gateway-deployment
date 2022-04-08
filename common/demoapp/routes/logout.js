const express = require('express');
var router = express.Router();

/* Perform Logout */
router.get('/', function(req, res, _next) {
  console.log("Perform Logout");
  req.session.authenticated = false;
  delete req.session.user;
  if (req.headers['iv-user']) {
    res.redirect('../pkmslogout');
  } else {
    res.redirect('/');
  }
});

module.exports = router;
