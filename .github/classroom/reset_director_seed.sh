#!/usr/bin/env bash
set -euo pipefail

RAILS_ENV=development bundle _1.15.3_ exec rails runner "Movie.delete_all; Movie.create!([{title: 'Star Wars', rating: 'PG', director: 'George Lucas', release_date: '1977-05-25', description: 'Space opera'}, {title: 'THX-1138', rating: 'R', director: 'George Lucas', release_date: '1971-03-11', description: 'Science fiction'}, {title: 'Blade Runner', rating: 'PG', director: 'Ridley Scott', release_date: '1982-06-25', description: 'Neo noir'}, {title: 'Alien', rating: 'R', director: nil, release_date: '1979-05-25', description: 'Space horror'}])"
