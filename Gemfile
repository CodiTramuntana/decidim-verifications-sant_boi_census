# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gemspec

DECIDIM_VERSION = ">= 0.17.0"

gem "decidim", DECIDIM_VERSION

group :development, :test do
  gem "bootsnap", require: true
  gem "byebug", ">= 10.0", platform: :mri
  gem "faker", "~> 1.8"
  gem "i18n-tasks", "~> 0.9.28"
  gem "listen"
end

group :development do
  gem "letter_opener_web", "~> 1.3.3"
  gem "web-console", "~> 3.5"
end
