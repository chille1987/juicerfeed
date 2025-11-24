# README

# Juicerfeed

Juicerfeed is a Ruby on Rails 8 app for exploring social posts from multiple sources (X, Facebook, Instagram…)

- **Sources** imported from a Mockend API
- **Posts** imported from the same API
- **Filtering** by platform, media type, source, and promoted flag
- **Infinite scroll** on the posts feed
- A small **analytics dashboard** (top posts by views, likes, comments, shares)

---

## Tech Stack

- **Ruby**: 3.4.6
- **Rails**: 8.1.x
- **Database**: PostgreSQL
- **HTTP client**: [Faraday](https://lostisland.github.io/faraday/)
- **Pagination**: [Pagy](https://ddnexus.github.io/pagy/)
- **Async jobs UI**: [Mission Control Jobs](https://github.com/rails/mission_control-jobs)
- **Frontend**:
    - Ruby on Rails Default Stack, Turbo, html.erb Files
    - Importmaps
    - Stimulus included by default but not used in this project
    - [Alpine.js](https://alpinejs.dev/)
    - Simple Vanilla CSS, no libraries

No Node / Webpacker / JS bundler is required.

---

## Getting Started

### 1. System dependencies

You’ll need:

- Ruby 3.4.6 (rbenv / rvm recommended)
- PostgreSQL (running locally)
- Bundler

### 2. Clone the Repo
```bash
git clone git@github.com:chille1987/juicerfeed.git
cd juicerfeed
```

### 3. Install Gems
```bash
bundle install
```

### 4. Credentials config/database.yml:
Juicerfeed uses credentials per environment(development, test, production) so you will need to create/edit development and test credentials by running:
```bash
bin/rails credentials:edit -e development
bin/rails credentials:edit -e test
````
Close each file to save it and then run:

```bash
bin/rails db:create db:migrate
```

### 5. Running the App
Development server
```bash
bin/rails server
```

### 6. Background Jobs
Juicerfeed used Rails built-in SolidQueue to run background jobs so you will need to run it in separate tab
```bash
bin/jobs start
```

In order to access UI for Background jobs under ```/jobs``` you will need a username and password setup in rails:credentials for mission control jobs.

```bash
bin/rails credentials:edit -e development
```

and add username and password for mission control jobs, you can add any username and password:
```bash
mission_control:
  http_basic_auth_user: juicerfeed
  http_basic_auth_password: juicerfeed
```

Development and test credentials are added in .gitignore so everyone who runs the app can have it's own credentials for development and test environment.

Restart the server and now you should be able to see UI for jobs under 
```bash
/jobs
```

### 7. Running the Test Suite
Juicerfeed uses Minitest

To run all tests:
```bash
bin/rails test
```

Some useful focused runs:
Model tests (e.g. scopes + validations):
```bash
bin/rails test test/models/post_test.rb
bin/rails test test/models/source_test.rb
```

Service tests:
```bash
bin/rails test test/services/fetch_sources_from_api_test.rb
bin/rails test test/services/fetch_posts_from_api_test.rb
```

Controller tests:
```bash
bin/rails test test/controllers/posts_controller_test.rb
bin/rails test test/controllers/analytics_controller_test.rb
```

### 8. Caching
Juicerfeed uses SolidCache to cache posts, in order to enable cache in Development you will need to run:
```bash
bin/rails dev:cache
```

More on SolidCache can be found here:

https://guides.rubyonrails.org/caching_with_rails.html#solid-cache

### 9.Deployment

This app is deployed to [juicerfeed.com](https://juicerfeed.com) on a Hetzner VPS server via kamal.

Typical steps (summary):

Configure config/deploy.yml for your server.

Ensure secrets are available to Kamal (e.g. via kamal secrets or environment).

```bash
bin/kamal setup
bin/kamal deploy
```

Exact Kamal configuration will depend on your server setup and registry credentials.

More info on how to deploy with Kamal can be found here:

[Kamal offical website](https://kamal-deploy.org/)

[DHH in action](https://www.youtube.com/watch?v=QC4b2teG_hc)
