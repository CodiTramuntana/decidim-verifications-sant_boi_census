# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gemspec

DECIDIM_VERSION = "~> 0.26.5"

gem "decidim", DECIDIM_VERSION

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
