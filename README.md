# Decidim::Verifications::SantBoiCensus

Decidim Verifications for Sant Boi Census.

## Usage

Decidim::Verifications::SantBoiCensus is based on the [Decidim::Verifications](https://github.com/decidim/decidim/tree/master/decidim-verifications#decidimverifications) and implements a custom verification method against the Municipal Census of Sant Boi. It will be available as a new authorization method in the decidim application.

## How it works
- The user must be registered as "normal" Decidim::User.
- Then, User goes to the Authorizations path and fill the fields Document number and Document type to verifiy the user.
- The data is sent to the web service and if response is succesful, meaning a citizen is found in the web service with the provided data, the user is verified.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-verifications-sant_boi_census'
```

And then execute:

```bash
bundle
```

SantBoiCensus verificator needs the following configuration values to perform requests:
- **url**, web service endpoint.
- **user**, web service credential.
- **password**, web service credential.
- **dboid**, web service identification number for Sant Boi.

Take care to add environment values to the secrets.yml file with:

```yaml
sant_boi_census:
  sant_boi_census_url: <%= ENV["SANT_BOI_CENSUS_URL"] %>
  sant_boi_census_user: <%= ENV["SANT_BOI_CENSUS_USER"] %>
  sant_boi_census_password: <%= ENV["SANT_BOI_CENSUS_PASSWORD"] %>
  sant_boi_census_dboid: <%= ENV["SANT_BOI_CENSUS_DBOID"] %>
```
## Testing

Node 16.1.9 is required!

1. Run `bundle exec rake test_app`.

2. Set the configuration values for the test app in `spec/decidim_dummy_app/config/secrets.yml`

```yaml
# The test stubs are configured to use the following values as to not reveal the real ones.
sant_boi_census:
  sant_boi_census_url: https://sant_boi_census_url
  sant_boi_census_user: sant_boi_census_user
  sant_boi_census_password: sant_boi_census_password
  sant_boi_census_dboid: sant_boi_census_dboid
```

3. Run tests with `bundle exec rspec`

## Versioning

`Decidim::Verifications::SantBoiCensus` depends directly on `Decidim::Verifications` in `0.25.2` version.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
