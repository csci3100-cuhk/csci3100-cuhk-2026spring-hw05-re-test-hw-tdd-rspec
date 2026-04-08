class MoviesController < ApplicationController
  def movie_params
    # TODO(hw05-director): after adding director column, permit :director here.
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    sort = params[:sort] || session[:sort]
    ordering = {}
    case sort
    when 'title'
      ordering = { title: :asc }
      @title_header = 'hilite'
    when 'release_date'
      ordering = { release_date: :asc }
      @date_header = 'hilite'
    end
    @all_ratings = Movie.all_ratings
    @selected_ratings = params[:ratings] || session[:ratings] || {}

    @selected_ratings = Hash[@all_ratings.map { |rating| [rating, rating] }] if @selected_ratings == {}
    @ratings_to_show_hash = @selected_ratings

    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      redirect_to sort: sort, ratings: @selected_ratings and return
    end
    @movies = Movie.where(rating: @selected_ratings.keys).order(ordering)
  end

  # TODO(hw05-director): add an action to find movies by the same director.
  # It should:
  # 1) find the target movie by id
  # 2) if director exists, load other movies by same director and render view
  # 3) if director is missing, flash warning and redirect to movies_path

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end
