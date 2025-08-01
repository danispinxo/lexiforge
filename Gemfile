source "https://rubygems.org"

ruby "3.1.1"
gem "rails", "~> 7.1.0"


gem "pg", "~> 1.1"
gem "puma", ">= 5.0"




gem "jbuilder"

gem "httparty"
gem "tzinfo-data", platforms: %i[ mswin mswin64 mingw x64_mingw jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri mswin mswin64 mingw x64_mingw ]
end

group :development do
  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
  
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-performance", require: false
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
