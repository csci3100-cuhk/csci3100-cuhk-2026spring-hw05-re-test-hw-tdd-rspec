class Movie < ActiveRecord::Base
  def self.all_ratings
    %w[G PG PG-13 NC-17 R]
  end

  def others_by_same_director
    Movie.where(director: director).where.not(id: id)
  end
end
