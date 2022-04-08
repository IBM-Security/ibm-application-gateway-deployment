const express = require('express');
var router = express.Router();

router.get('/', function(req, res, _next) {

    var iat = req.headers.iat;
    var time = 10000;
    if (iat) {
      time = Date.now() - (iat*1000);
    }
    console.log(time);
    if ( time > 2000)
    {
      res.redirect('/esign');
      return;
    }


    // Display Home Page
    res.render('esign');
});

module.exports = router;
