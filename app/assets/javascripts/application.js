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
//= require jquery_ujs
//= require_tree .


// Turbolinks.BrowserAdapter.prototype.showProgressBarAfterDelay = function() {
//   return this.progressBarTimeout = setTimeout(this.showProgressBar, 0);
// };

// function generateProgressBar(){
//     setInterval(function(){
//       console.log($('#pb').value)
//       var oldValue = document.getElementById('pb').value
//       document.getElementById('pb').value = oldValue + 1
//     }, 5)
//   }

// console.log(window.location.search.substring(1).split('=')[0] == 'n_jid');
// var params = window.location.search.substring(1).split('=')
// if(params[0] == 'n_jid')
//   setInterval(function() {
//       console.log("meow")
//       $.get('is_still_loading', {n_jid: parseInt(params[1])}, function(data) {
//          if (data.success) {
//            // Done loading, redirect or whatever
//            console.log(data)
//          }
//     })
//   }, 1000)

relatedSearches = []

$(document).ready(function() {
  userCreds = parseInt($("#user-credits").text().split(": ")[1])
  console.log(userCreds)
  $("input[name=related-search]:checked").each(function(){
    relatedSearches.push($(this).val());
  });
  console.log(relatedSearches.length)
  $("#related-search-cost").text("Credits Needed: "+ relatedSearches.length)
   if(relatedSearches.length > userCreds){
     $("#submit").text("Get Credits To Apply");
      $("#submit").attr('disabled','disabled')
   }else{
     $("#submit").text("Auto Apply");
       $("#submit").removeAttr('disabled');
   }
});

function getCheckedSearches(){
  relatedSearches = []
  $("input[name=related-search]:checked").each(function(){
    relatedSearches.push($(this).val());
    if(relatedSearches.length > userCreds){
      $("#submit").text("Get Credits To Apply")
      $("#submit").attr('disabled','disabled')
    }else{
      $("#submit").text("Auto Apply");
      $("#submit").removeAttr('disabled');
    }
  });
  console.log(relatedSearches.length)
  $("#related-search-cost").text("Credits Needed: "+ relatedSearches.length)
}

function checkUserCredits(){
  // console.log(relatedSearches.length)
    j_id=window.location.search.split("=")[1]
    $.post(window.location.origin+'/apply_to_related_searches', {j: j_id, r_searches: relatedSearches})
    $('form.edit_user').submit();

}
