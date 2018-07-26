# Address Validator

A simple address validator using the Google's Geocode API

## Dependencies
* ruby
* rails
* redis
* postgres

## Installation
### Run locally
* Clone repo
* `cd address-validator`
* `bundle install`
* `rails s`

### Run docker locally
* Clone repo
* Alter address-validator/config/database.yml to use Postgres as the DB
* `sh docker-launch.sh`

# Testing
* rails db:test