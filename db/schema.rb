# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150928171848) do

  create_table "actors", :force => true do |t|
    t.string   "name"
    t.integer  "tmdb_id"
    t.integer  "times_said", :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.float    "popularity"
  end

  add_index "actors", ["tmdb_id"], :name => "index_actors_on_tmdb_id"

  create_table "actors_games", :id => false, :force => true do |t|
    t.integer "actor_id"
    t.integer "game_id"
  end

  create_table "actors_movies", :id => false, :force => true do |t|
    t.integer "actor_id"
    t.integer "movie_id"
  end

  create_table "games", :force => true do |t|
    t.integer  "final_computer_score"
    t.integer  "final_player_score"
    t.integer  "winner"
    t.integer  "user_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "games_movies", :id => false, :force => true do |t|
    t.integer "game_id"
    t.integer "movie_id"
  end

  create_table "movies", :force => true do |t|
    t.string   "title"
    t.integer  "year"
    t.integer  "tmdb_id"
    t.integer  "times_said",      :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "tmdb_popularity", :default => 0
  end

  add_index "movies", ["tmdb_id"], :name => "index_movies_on_tmdb_id"

  create_table "scores", :force => true do |t|
    t.integer  "computer",   :default => 0
    t.integer  "player",     :default => 0
    t.integer  "game_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "username"
    t.string   "password_digest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end
