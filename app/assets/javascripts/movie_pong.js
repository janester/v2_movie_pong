$(function(){
  $("#new_movie_btn").click(change_start_movie);
  $("#entered_actor_btn").click(get_entered_info);
  get_start_movies();
  hide_scoreboard();
  $('body').on("click", "#myModal", close_modal);
});

var start_movies = [];
var computer_score = 0;
var player_score = 0;
var i = 1;
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
function get_start_movies()
{
  var game_id = $("#game").text();
  $.ajax({
  dataType: 'json',
  type: "get",
  url: "/games/"+game_id+"/get_info"
  }).done(update_start_movies);
  return false;
}

function update_start_movies(movies)
{
  start_movies = movies;
  change_start_movie();
}

function change_start_movie()
{
  var movie = start_movies.shift();
  if(movie === undefined)
  {
    get_start_movies();
  }
  else
  {
    $("#movie_title").text(movie.title);
    $("#movie_tmdb").text(movie.tmdb_id += "");
  }

}
function hide_scoreboard()
{
  $("#pageScoreboard").hide();
}
// START MOVIES*****************************************

// PLAY*************************************************
function get_entered_info()
{
  var movie = $("#movie_tmdb").text();
  var actor = $("#entered_actor").val();
  var game_id = $("#game").text();

  $.ajax({
  dataType: 'json',
  type: "post",
  url: "/games/"+game_id+"/play",
  data: {movie:movie, actor:actor, game_id:game_id}
  }).done(update_page);
  return false;
}
function hide_start_stuff()
{
  $("#or").hide();
  $("#new_movie_btn").hide();
}

function update_page(message)
{
  hide_start_stuff();
  console.log(message);
  if(message.movie === undefined)
  {
    update_score(message);
  }
  else
  {
    $("#movie_title").text(message.movie.title);
    $("#movie_tmdb").text(message.movie.tmdb_id+="");
    $("#entered_actor").val("");
  }

}
// PLAY*************************************************

// NEW ROUND********************************************
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
    $("#modalText").text("Sorry! You just got ponged");
    show_modal();
    $("#modalScoreboard").children().children().first().children().text(computer_score);
    $("#modalScoreboard").children().children().last().children().text(player_score);
    $("#play_again_btn").show();

  }
  else if(computer_score === 4)
  {
    $("#modalText").text("Woah. You're Smarter than a Computer.");
    show_modal();
    $("#modalScoreboard").children().children().first().children().text(computer_score);
    $("#modalScoreboard").children().children().last().children().text(player_score);
    $("#play_again_btn").show();

  }
  else if(last.computer === 0)
  {
    $("#modalText").text(message.message);
    show_modal();
    $("#modalScoreboard").children().children().first().children().text(computer_score);
    $("#modalScoreboard").children().children().last().children().text(player_score);
    $("#play_again_btn").hide();
  }
  else
  {
    $("#modalText").text(message.message);
    show_modal();
    $("#modalScoreboard").children().children().first().children().text(computer_score);
    $("#modalScoreboard").children().children().last().children().text(player_score);
    $("#play_again_btn").hide();

  }
}


function update_page_score()
{
  $("#pageScoreboard").show();
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