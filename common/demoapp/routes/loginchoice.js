const express = require('express');
var router = express.Router();

router.get('/', function(req, res, _next) {
    // Display Home Page
    res.render('loginchoice');
});

module.exports = router;
