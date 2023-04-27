# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gemspec

DECIDIM_VERSION = "~> 0.27.2"

gem "decidim", DECIDIM_VERSION

# temporal solution while gems embrace new psych 4 (the default in Ruby 3.1) behavior.
gem "psych", "< 4"

group :development, :test do
  gem "bootsnap", require: true
  gem "byebug", ">= 10.0", platform: :mri
  gem "faker"
  gem "i18n-tasks"
  gem "listen"
end

group :development do
  gem "letter_opener_web"
  gem "web-console"
end
