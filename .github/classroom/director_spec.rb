require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'uri'

raw_uri = ENV.fetch('HEROKU_URI', '').strip
raise 'HEROKU_URI is not set' if raw_uri.empty?

raw_uri = "http://#{raw_uri}" unless raw_uri.match?(%r{^http://})
uri = URI.parse(raw_uri)
host = URI::HTTP.build(host: uri.host, port: uri.port).to_s
movies_url = URI.join(host, 'movies').to_s

def details_page_for(agent, movies_url, title)
  page = agent.get(movies_url)
  details_link = page.links.find { |link| link.text&.include?("More about #{title}") }
  details_link ||= page.links.find do |link|
    link.text&.include?(title) && link.href.to_s.include?('/movies/')
  end
  raise "Could not find movie details link for #{title}" if details_link.nil?

  details_link.click
end

def same_director_page_for(agent, movies_url, title)
  details_page = details_page_for(agent, movies_url, title)
  link = details_page.links.find { |candidate| candidate.text&.include?('Find Movies With Same Director') }
  raise "Could not find same director link for #{title}" if link.nil?

  link.click
end

describe 'App' do
  it 'responds to simple request', points: 5 do
    agent = Mechanize.new
    page = agent.get(movies_url)
    expect(page).not_to be_nil
  end
end

describe 'Director feature' do
  it 'new page includes director field', points: 10 do
    agent = Mechanize.new
    page = agent.get(URI.join(host, 'movies/new'))
    form = page.forms.first
    expect(form).not_to eq(nil)
    expect(form.field_with(name: 'movie[director]')).not_to eq(nil)
  end

  it 'edit page includes director field', points: 10 do
    agent = Mechanize.new
    details_page = details_page_for(agent, movies_url, 'Alien')
    edit_link = details_page.links.find { |link| link.text == 'Edit' }
    expect(edit_link).not_to eq(nil)
    edit_page = edit_link.click
    form = edit_page.forms.first
    expect(form).not_to eq(nil)
    expect(form.field_with(name: 'movie[director]')).not_to eq(nil)
  end

  it 'updating movie persists director', points: 15 do
    agent = Mechanize.new
    details_page = details_page_for(agent, movies_url, 'Alien')
    edit_link = details_page.links.find { |link| link.text == 'Edit' }
    expect(edit_link).not_to eq(nil)
    edit_page = edit_link.click
    form = edit_page.forms.first
    expect(form).not_to eq(nil)
    form.field_with(name: 'movie[director]').value = 'Ridley Scott'
    form.submit

    updated_details = details_page_for(agent, movies_url, 'Alien')
    expect(updated_details.body).to include('Ridley Scott')
  end

  it 'show page displays director', points: 10 do
    agent = Mechanize.new
    details_page = details_page_for(agent, movies_url, 'Star Wars')
    expect(details_page.body).to include('George Lucas')
  end

  it 'show page has same director link', points: 10 do
    agent = Mechanize.new
    details_page = details_page_for(agent, movies_url, 'Star Wars')
    link = details_page.links.find { |candidate| candidate.text&.include?('Find Movies With Same Director') }
    expect(link).not_to eq(nil)
  end

  it 'same director page includes matched movies', points: 15 do
    agent = Mechanize.new
    page = same_director_page_for(agent, movies_url, 'Star Wars')
    expect(page.body).to include('THX-1138')
  end

  it 'same director page excludes different director movies', points: 10 do
    agent = Mechanize.new
    page = same_director_page_for(agent, movies_url, 'Star Wars')
    expect(page.body).not_to include('Blade Runner')
  end

  it 'movie without director redirects with warning', points: 15 do
    agent = Mechanize.new
    details_page = details_page_for(agent, movies_url, 'Alien')
    link = details_page.links.find { |candidate| candidate.text&.include?('Find Movies With Same Director') }
    expect(link).not_to eq(nil)
    page = link.click

    expect(page.uri.path).to eq('/movies')
    expect(page.body.downcase).to match(/no director/)
  end
end
