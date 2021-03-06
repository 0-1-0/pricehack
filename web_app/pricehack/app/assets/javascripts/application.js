// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require Chart.bundle
//= require chartkick
//= require chartkick
//= require jquery_ujs
//= require turbolinks
//= require_tree .

$(document).ready(function(){
  $("#search_btn").click(function(){
  
    var url1 = $( "input[type=text][name=id]" ).val();

    $.ajax({
          url: "find_amazon_info/",
          type: "post",
          data: {amazon_url: url1},
          success: function(resp){ 
            $(".title").text(resp['title']);
          }
      });

     $.ajax({
        url: 'find_amazon_prices/',
        type: 'POST', 
        data: {id: url1},          
        success: function (resp) { 
            $(".old_prices").text('Offers: ' + resp['prices']);
        } 
      });

     $.ajax({
        url: "find_ebay/",
        type: "get",
        dataType: 'json',
        success: function(data){ 
          var keys = [];
          var values = [];
          $(".ebay").append("<h3>Ebay</h3>");
          for (var i = 0; i < data['ebay'].length; i++) {
              for (var key in data['ebay'][i]) {
                  if (data['ebay'][i].hasOwnProperty(key)) {
                      $(".ebay").append("Title" + key + "<br>");
                      $(".ebay").append("Price: " + data['ebay'][i][key] + "<br>");
                  }
              }
          }
        },
        async: false
    });
  });
})
