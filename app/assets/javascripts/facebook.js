function facebook_setup(appid) {
        window.fbAsyncInit = function() {
          FB.init({
            appId      : appid,
            status     : true, 
            cookie     : true,
            xfbml      : true,
            oauth      : true,
          });
          FB.Event.subscribe('auth.login', function(r)
              {
                  console.log(r.status);

                  if ( r.status === 'connected' )
                  {
                      // a user has logged in
                  }
              }
          );
        };

        (function(d){
           var js, id = 'facebook-jssdk'; if (d.getElementById(id)) {return;}
           js = d.createElement('script'); js.id = id; js.async = true;
           js.src = "//connect.facebook.net/en_US/all.js";
           d.getElementsByTagName('head')[0].appendChild(js);
         }(document));
       }