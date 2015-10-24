class MovieDb
  BASE_PATH = "http://api.themoviedb.org/3/"
  class << self
    def get_movie_with_credits(id)
      path = "movie/#{id}/"
      params = default_params.merge(append_to_response: "credits")
      make_request(path, params)
    end

    def get_movie(id)
      path = "movie/#{id}"
      make_request(path)
    end

    def get_popular_movies
      path = "movie/popular"
      response = make_request(path)
      response[:results]
    end

    def get_movie_credits(id)
      path = "movie/#{id}/credits"
      response = make_request(path)
      response[:cast]
    end

    def get_actor_credits(id)
      path = "person/#{id}/movie_credits"
      response = make_request(path)
      response[:cast]
    end

    def get_actor(id)
      path = "person/#{id}"
      make_request(path)
    end

    def make_request(path, params = default_params)
      url = BASE_PATH + path
      response = Typhoeus.get(url, params: params)
      JSON(response.body).with_indifferent_access
    end

    def default_params
      { api_key: TMDB }
    end
  end
end
