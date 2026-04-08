class Movie < ActiveRecord::Base
  def self.all_ratings
    %w[G PG PG-13 NC-17 R]
  end

  # TODO(hw05-director): implement a model method to find other movies
  # with the same director as this movie.
end
