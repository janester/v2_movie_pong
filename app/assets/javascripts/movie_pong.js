$(function(){
  $("#new_movie_btn").click(precurse_change_start_movie);
  $("#entered_actor_btn").click(get_entered_info);
  $("#start_game_btn_disabled").click(function(){ alert("You Must Be Logged In to Play");});
  get_start_movies();
  $("body").on("click", ".reveal-modal-bg", close_modal);
  // $('body').on("click", "#myModal", close_modal);
});

var start_movies = [];
var computer_score = 0;
var player_score = 0;
var i = 1;
var actors = [];
var actor_objs = [];

// MODALS***********************************************
function show_modal()
{
  $('#myModal').foundation('reveal', 'open');
}

function close_modal()
{
  $('#myModal').foundation('reveal', 'close');
  $("#modalText").text("");
  update_page_score();
}
// MODALS***********************************************

// START MOVIES*****************************************

//probably a better solution to this
function precurse_change_start_movie(e){
  e.preventDefault();
  change_start_movie();
}


function get_start_movies()
{
  if ($("#entered_actor_btn").length > 0) {
    spin_init();
    var game_id = $("#game").text();
    $.ajax({
    dataType: 'json',
    type: "get",
    url: "/games/"+game_id+"/get_info"
    }).done(update_start_movies);
    return false;
  }
}

function update_start_movies(info)
{
  start_movies = info.movies;
  actor_objs = info.actors;
  update_actor_autocomplete(get_actor_names());
  change_start_movie();
}

function get_actor_names(){
  return _.map(actor_objs, function(x) {return x.name; });
}

function get_actor_id(name){
  actor = _.find(actor_objs, function(x) { return x.name == name; });
  return actor.tmdb_id;
}


function update_actor_autocomplete(array) {
  actors.push(array);
  actors = _.uniq(_.compact(_.flatten(actors)));
  $('input#entered_actor').autocomplete({
    source: actors
  });
}

function change_start_movie()
{
  $("#spinner").empty();
  var movie = start_movies.shift();
  if(movie === undefined)
  {
    get_start_movies();
  }
  else
  {
    $("#movie_title").text(movie.title +" ("+movie.year+")");
    $("#movie_tmdb").text(movie.tmdb_id += "");
  }

}
// START MOVIES*****************************************

// PLAY*************************************************
function get_entered_info(e)
{
  e.preventDefault();
  var movie = $("#movie_tmdb").text();
  var actor = $("#entered_actor").val();
  var game_id = $("#game").text();

  $.ajax({
  dataType: 'json',
  type: "post",
  url: "/games/"+game_id+"/play",
  error: function(error){
    $("#spinner").empty();
    console.log(error);
    alert("Sorry Something Went Wrong...");
    location.reload();
  },
  data: {movie_id:movie, actor_id: get_actor_id(actor), game_id:game_id}
  }).done(update_page);
  spin_init();
  return false;
}
function hide_start_stuff()
{
  $("#or").hide();
  $("#new_movie_btn").hide();
}

function update_page(message)
{
  if (message.actors != undefined) {
    actor_objs = message.actors
    update_actor_autocomplete(get_actor_names());
  }
  hide_start_stuff();
  $("#spinner").empty();
  console.log(message);
  if(message.movie === undefined)
  {
    update_score(message);
  }
  else
  {
    var movie_string = message.movie.title+" ("+message.movie.year+")";
    $("#movie_title").text(movie_string);
    $("#movie_tmdb").text(message.movie.tmdb_id+="");
    $("#entered_actor").val("").focus();
  }

}
// PLAY*************************************************

// NEW ROUND********************************************
function show_modal_with_text(text, show){

  if ($("html").hasClass("touch")) {
    alert(text);
    if (show) {
      window.location = $("#play_again_btn").attr("href");
    }
    else {
      update_page_score();
    }
  }
  else {
    if (show) {
      $("body").on("click", ".reveal-modal-bg", function(){window.location = $("#play_again_btn").attr("href");});
      $("#play_again_btn").show();
    }
    else {
      $("#play_again_btn").hide();
    }
    $("#modalText").text(text);
    show_modal();
    $("#modalScoreboard").children().children().first().children().text(computer_score);
    $("#modalScoreboard").children().children().last().children().text(player_score);
  }

}

function update_score(message)
{
  i += 1;
  computer_score = 0;
  player_score = 0;
  console.log(message);
  _.each(message.scores, function(x){computer_score += x.computer;});
  _.each(message.scores, function(x){player_score += x.player;});
  var last = _.last(message.scores);
  if(player_score === 4)
  {
    show_modal_with_text("Sorry! You just got ponged", true);
  }
  else if(computer_score === 4)
  {
    show_modal_with_text("Woah. You're Smarter than a Computer.", true);
  }
  else if(last.computer === 0)
  {
    show_modal_with_text(message.message, false);
  }
  else
  {
    show_modal_with_text(message.message, false);
  }
}


function update_page_score()
{
  $("#pageScoreboard").removeClass("hide");
  $("#pageScoreboard").children().first().children().text(computer_score);
  $("#pageScoreboard").children().last().children().text(player_score);
  show_start_stuff();
  update_round_count();
  get_start_movies();
}

function show_start_stuff()
{
  $("#or").show();
  $("#new_movie_btn").show();
  $("#entered_actor").val("");
}

function update_round_count()
{
  var r = "Round #"+i;
  $("#round_count").text(r);
}
// NEW ROUND********************************************

//SPINNER***********************************************
function spin_init()
{
  var opts = {
  lines: 9, // The number of lines to draw
  length: 21, // The length of each line
  width: 5, // The line thickness
  radius: 24, // The radius of the inner circle
  corners: 0.6, // Corner roundness (0..1)
  rotate: 0, // The rotation offset
  color: '#FF1F00', // #rgb or #rrggbb
  speed: 1, // Rounds per second
  trail: 50, // Afterglow percentage
  shadow: false, // Whether to render a shadow
  hwaccel: false, // Whether to use hardware acceleration
  className: 'spinner', // The CSS class to assign to the spinner
  zIndex: 2e9, // The z-index (defaults to 2000000000)
  top: 'auto', // Top position relative to parent in px
  left: 'auto' // Left position relative to parent in px
};
  var target = document.getElementById('spinner');
  var spinner = new Spinner(opts).spin(target);
}

//SPINNER***********************************************

