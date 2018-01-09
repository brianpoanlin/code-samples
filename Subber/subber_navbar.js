$(window).scroll(function() {
            var scrn_width=$(window).width();
            if (scrn_width>768)
            {
                var height = $(window).scrollTop();
                var op_new=(height/60)-1.0125;
                var dis_op=1-op_new;

                if(height>60 && height<200) {
                    $(".navbar-default").css("background-color", "rgba(92,108,126," + op_new + ")");
                    $(".Title_Word").css("opacity",dis_op);

                }
                else if (height<60)
                {
                    $(".navbar-default").css("background-color", "rgba(92,108,126,0");   
                    $(".Title_Word").css("opacity","1");
                }
               else
                {
                    $(".navbar-default").css("background-color", "rgba(92,108,126,0.95");  
                    $(".Title_Word").css("opacity","0");
                    $(".navbar-default").animate({height:'60px'}, 500);
                    $(".navbar-default .navbar-brand").animate({height:'60px', marginTop:'-7px'}, 500);
                    $(".navbar-default .navbar-nav > li > a").animate({height:'60px',fontSize:'20px',top:'10px'}, 500);
                    $(".navbar-default li.selected").animate({height:'54px',borderBottomWidth:'1px'}, 500);


                }
            }
});