const express = require('express');
var router = express.Router();

// Handle GET request to /profile
router.get('/', function(req, res, _next) {
  console.log("START profile GET Function");
  // If session is unauthenticated, redirect to user login
  if (!req.session.authenticated) {
    req.session.afterlogin = "profile";
    res.redirect('/userlogin');
  } else { // user is authenticated

    var attributes = ["name","userName","email","mobile_number","realmName","tenantId","uid"]
    var userJson = {};
    for (attr of attributes) {
      userJson[attr] =  req.session.user[attr] || "---";
}
    // Display Profile page
    res.render('profile', {
      title: 'User Profile',
      userJson: userJson
    });
  }
});

module.exports = router;
