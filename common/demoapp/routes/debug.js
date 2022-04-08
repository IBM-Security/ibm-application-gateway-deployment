const express = require('express');
var router = express.Router();

// Handle GET request to /profile
router.get('/', function(req, res, _next) {
  console.log("START debug GET Function");
  // If session is unauthenticated, redirect to user login
  if (!req.session.authenticated) {
    req.session.afterlogin = "debug";
    res.redirect('/userlogin');
  } else { // user is authenticated

    // Display Profile page
    res.render('debug', {
      title: 'Debug Information',
      userJson: req.session.user,
      headersJson: req.headers
    });
  }
});

module.exports = router;
