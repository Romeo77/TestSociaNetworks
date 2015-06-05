Parse.Cloud.define("signUpUser", function(request, response) {
 
 Parse.Cloud.useMasterKey();
 var user = new Parse.User();
 user.set("email", request.params.email);
 user.set("password", request.params.password);
 user.set("username", request.params.username);
 user.set("firstname", request.params.firstname);
 user.set("secondname", request.params.secondname);
 user.set("birthday", request.params.birthday);
  
    user.save().then(function(user) {
        response.success(user);
    }, function(error){ 
        response.error(error)
    });
    });
    