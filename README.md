# TDD with RSpec

In this assignment you will use a combination of Acceptance and
Unit/Functional 
tests with the Cucumber and RSpec tools to add a "find movies with same
director" feature to RottenPotatoes.


Learning Goals
--------------
After you complete this assignment, you should be able to:

* Create and run simple Cucumber scenarios to test a new feature

* Use RSpec to create unit and functional tests that drive the creation
of app code that lets the Cucumber scenario pass 

* Understand where to modify a Rails app to implement the various parts
of a new feature, since a new feature often touches the database schema,
model(s), view(s), and controller(s)

* Use continuous integration with [Travis](http://travis-ci.org) to
continuously monitor test coverage and passing status

Specifically, you will add two features to RottenPotatoes: "User can
include name of Director with a movie", and "Given a movie with a
director, user can search for other movies with same director".
You will use TDD to develop these features and achieve 100% statement coverage (C0)
of RSpec tests for the features.


Introduction and Setup
----

## Travis CI: continuous integration and test coverage

In this assignment you'll use [Travis](http://travis-ci.org) to
continuously monitor if your tests are passing and what your C0 test coverage is.  If you don't already
have a free Travis account, create one; then add your fork of this
repo to the "watched repos".  You will have to confirm on GitHub that
Travis should be allowed access to your public repo; this allows Travis
to be notified when any code pushes occur.

The idea behind CI is simple: it can be set up to automatically run
tasks related to testing and verification each time you push new code.
For Rails apps that have been set up with Cucumber and RSpec, the tasks
`rake cucumber` and `rake rspec` run all of the Cucumber scenarios and
RSpec tests, respectively.  We will also include an additional task 
that measures test coverage, by tracking which lines of which files in your
app are actually "touched" by any test code.

1. On the Travis CI website, locate the instructions to add a "Travis CI
badge" to this `README.md` file.  Commit and push the modified
`README.md` and verify you can see the Travis badge render correctly on
the front page of your repo.

2. Take a look at the `.travis.yml` file in this project, which gives
Travis instructions on what to do each time code is pushed to GitHub.
Satisfy yourself that you understand the meaning of each directive in
that file.

1. In particular, notice the lines that collect test coverage information and send it to CodeClimate, a hosted
code-analysis service, to report on your test coverage.  To set this up:
Setup a free account (we recommend using "Sign In With GitHub") on `codeclimate.com`, and add the repo for this
homework.  Go to the repo's settings in CodeClimate, select the Test Coverage set of options, and
copy the CodeClimate Test Reporter ID (a long hexadecimal string).  **Copy this string to the `.travis.yml` file** as the value 
for the global option `CC_TEST_REPORTER_ID`.  **If you don't do this step, Travis will be unable to report 
test coverage results to CodeClimate.**

**Part 0: Setup - ensure tests run locally**

If you are using GitHub Codespaces for this assignment, the development
environment is preconfigured. You can directly run the checks below:

```
bundle exec rake db:setup
bundle exec rake rspec
bundle exec rake cucumber
```

1. The commands above should run without errors before you push your code.
We have provided framework files in `features/` and `spec/`; you should
add/complete the tests needed for this assignment.

1. Next, set up test coverage collection.  Add the following code **BEFORE ANYTHING ELSE ON LINE ONE** of both
`spec/rails_helper.rb` and `features/support/env.rb`:

```ruby 
require 'simplecov' 
SimpleCov.start 'rails' 
```

Now whenever you run `rspec` or `cucumber`, SimpleCov will generate a coverage report
in a directory named `coverage/`.  SimpleCov can intelligently merge the results, so running
the tests for Rspec does not overwrite the coverage results from
SimpleCov and vice versa.  Verify that coverage reporting is working.

1. When you're satisfied that the tests and coverage reporting work locally, commit and push all your changes, then head over
to `travis-ci.org`.  You should see that a build (continuous integration run) has begun; since there are no tests yet,
it should run very quickly.  In particular, inspect the output to make sure the process of collecting
test coverage results and sending them to CodeClimate was successful.

1. Finally, check CodeClimate for the results of analyzing both code quality and test coverage on your app.
For test coverage, you can click on the name of any file in CodeClimate, then click the Code tab, then check the 
Coverage box.  Lines that were "touched" by some test will be highlighted.

### Student Local Self-Check Guide (before push)

You should verify your implementation locally before pushing.

**Autograder scope note:** this homework is graded on the `director` feature flow
(`add/edit director`, `find movies with same director`, and sad path handling).
There is no TMDB `/search` grading in this version.

#### Option A: Use GitHub Codespaces (recommended)

1. Open your assignment repository in Codespaces.
2. Wait for container setup.
3. Run:

```sh
bundle exec rake db:setup
bundle exec rake rspec
bundle exec rake cucumber
```

#### Option B: Local environment

If you work locally, use Ruby 2.7.x and run:

```sh
bundle exec rake db:setup
bundle exec rake rspec
bundle exec rake cucumber
```

#### GitHub Action autograder checks (100 points)

The workflow checks these behaviors:

1. App responds to `/movies` (5)
2. New page has `director` input field (10)
3. Edit page has `director` input field (10)
4. Updating a movie persists director changes (15)
5. Show page displays director info for a movie with director (10)
6. Show page has a "Find Movies With Same Director" link (10)
7. Similar-director page includes expected matching movie(s) (15)
8. Similar-director page excludes movies by different directors (10)
9. Movie without director follows sad path (redirect + warning) (15)

#### Manual walkthrough you can run locally

Use this seed set for manual checks:

- `Star Wars` / `George Lucas`
- `THX-1138` / `George Lucas`
- `Blade Runner` / `Ridley Scott`
- `Alien` / no director

Then verify:

1. On `movies/new` and `movies/:id/edit`, a `Director` field is present.
2. Editing `Alien` and saving `Director = Ridley Scott` persists to the show page.
3. On `Star Wars` show page, director appears and the same-director link exists.
4. Clicking same-director link from `Star Wars` includes `THX-1138` and excludes `Blade Runner`.
5. On `Alien` show page, clicking same-director link goes back to home/list page and shows a warning about missing director info.

#### Suggested file areas to test

1. Route for similar-director lookup in `config/routes.rb`
2. Controller action handling same-director search in `app/controllers/movies_controller.rb`
3. Model query logic in `app/models/movie.rb`
4. View updates in `app/views/movies/show.html.haml`, `app/views/movies/new.html.haml`, and `app/views/movies/edit.html.haml`
5. Your own RSpec and Cucumber tests in `spec/` and `features/`



**Part 1: add a Director field to Movies**

Create and apply a migration that adds the Director field to the movies
table.  The director field should be a string containing the name of the
movie's director.  HINT: use the [`add_column` method of
`ActiveRecord::Migration`](http://apidock.com/rails/ActiveRecord/ConnectionAdapters/SchemaStatements/add_column)
to do this.

Remember that once the migration is applied, you also have to do `rake
db:test:prepare` to load the new post-migration schema into the test
database!

Remember to add the new `director` attribute to the list of movie
attributes allowed in `params`, in the `movie_params` method in
`movies_controller.rb`. 


**Part 2: use Acceptance and Unit tests to get new scenarios passing**

We've provided [three Cucumber scenarios](http://pastebin.com/L6FYWyV7)
to drive creation of the happy path of Search for Movies by Director.
The first lets you add director info to an existing movie, and doesn't
require creating any new views or controller actions (but does require
modifying existing views, and will require creating a new step
definition and possibly adding a line or two to
`features/support/paths.rb`).

The second lets you click a new link on a movie details page "Find
Movies With Same Director", and shows all movies that share the same
director as the displayed movie.  For this you'll have to modify the
existing Show Movie view, and you'll have to add a route, view and
controller method for Find With Same Director.

The third handles the sad path, when the current movie has no director
info but we try to do "Find with same director" anyway.

Going one Cucumber step at a time, use RSpec to create the appropriate
controller and model specs to drive the creation of the new controller
and model methods.  At the least, you will need to write tests to drive
the creation of:

* a RESTful route for Find Similar Movies (HINT: use the 'match' syntax
for routes as suggested in "Non-Resource-Based Routes" in Section 4.1 of
ESaaS). You can also use the key :as to specify a name to generate
helpers (i.e. `search_directors_path`)
http://guides.rubyonrails.org/routing.html 

Note: you probably won't test
this directly in rspec, but a line in Cucumber or rspec will fail if the
route is not correct.

* a controller method to receive the click on "Find With Same Director",
and grab the `id` (for example) of the movie that is the subject of the
match (i.e. the one we're trying to find movies similar to)

* a model method in the Movie model to find movies whose director
matches that of the current movie. Note: This implies that you should
write at least 2 specs for your controller: 

1) When the specified movie has a director, it should...  

2) When the specified movie has no director, it should ... 

and 2 specs for your model: 

1) it should find movies by the same director and 

2) it should not find movies by different directors.

It's up to you to decide whether you want to handle the sad path of "no
director" in the controller method or in the model method, but you must
provide a test for whichever one you do. Remember to include the line
`require 'rails_helper'` at the top of your *_spec.rb files.

You may find this [RSpec cheat sheet](https://devhints.io/rspec) helpful.

Improve your test coverage by adding unit tests for untested or
undertested code. Specifically, you can write unit tests for the
`index`, `update`, `destroy`, and `create` controller methods.

**Submission:**

Here are the instructions for submitting your assignment for
grading. Submit a zip file containing the following files and
directories of your app:

* app/ config/ db/migrate features/ spec/ Gemfile Gemfile.lock

If you modified any other files, please include them too. If you are on
a *nix based system, navigate to the root directory for this assignment
and run

```sh $ cd ..  $ zip -r hw5.zip rottenpotatoes/app/
rottenpotatoes/config/ rottenpotatoes/db/migrate
rottenpotatoes/features/ rottenpotatoes/spec/ rottenpotatoes/Gemfile
rottenpotatoes/Gemfile.lock ```

This will create the file hw5.zip, which you will submit.

IMPORTANT NOTE: Your submission must be zipped inside a rottenpotatoes/
folder so that it looks like so:

``` $ tree .  └── rottenpotatoes
    ├── Gemfile ├── Gemfile.lock ├── app ...
```
