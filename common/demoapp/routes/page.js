const express = require('express');
var router = express.Router();

/* GET page. */
router.get('/*', function(req, res, _next) {
  var path = req._parsedUrl.path;
  var page = req._parsedUrl.pathname.substring(1);

  res.render('page', {
   title: "GET " + page,
   pageData: {"Full Path":path}
  });
});

/* POST page. */
router.post('/*', function(req, res, _next) {
  var path = req._parsedUrl.path;
  var page = req._parsedUrl.pathname.substring(1);

  res.render('page', {
   title: "POST " + page,
   pageData: {"Full Path":path,
              "Attr1":req.body.attr1,
              "Attr2":req.body.attr2
             }
  });
});

module.exports = router;
