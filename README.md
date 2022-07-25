# doppler-env

The doppler-env gem automates the injection of Doppler secrets as environment variables into any Ruby application and works in the terminal, RubyMine, and Visual Studio Code.
## Motivation

The Doppler CLI provides the easiest method of injecting secrets into your application:

```sh
doppler run -- ruby app.rb
```

But when debugging with RubyMine or Visual Studio Code, a vendor-specific Ruby entry-point is used, preventing the Doppler CLI from acting as the application runner. At Doppler, we go to great lengths to [prevent secrets ending up on developer's machines](https://blog.doppler.com/how-to-prevent-secrets-from-ending-up-on-developers-machines) so downloading secrets to a .env file wasn't an option.

You can replicate dotenv gem behavior by requiring doppler-env in your project to inject Doppler secrets.

## Setup

Ensure you have [installed the Doppler CLI](https://docs.doppler.com/docs/enclave-installation) locally and have [created a Doppler Project](https://docs.doppler.com/docs/create-project). Then authorize the Doppler CLI to retrieve secrets from your workplace by running:

```sh
doppler login
```

Then add `doppler-env` to your Bundler `Gemfile`:

```ruby
gem "doppler-env"
```

## Configuration

First, require `doppler-env` in your project. Make sure it's required and loaded before any other libraries. To do this you can require the library and manually call `Doppler.load`:

```ruby
# will cause your Doppler secrets to get injected into ENV for your application,
# but will not override any pre-existing ENV variables.
require "doppler-env"
DopplerEnv.load
```

or

```ruby
require "doppler-env/load"
```

You can also force it to override pre-existing ENV variables with:

```ruby
require "doppler-env"
DopplerEnv.load!
```

After you have the library loading in your application, you need to configure which secrets to fetch for your application by either using the CLI in the root directory of your application:

```sh
doppler setup
```

or by setting the `DOPPLER_PROJECT` and `DOPPLER_CONFIG` environment variables in your debug configuration within RubyMine or Visual Studio Code.

Now whenever the Ruby interpreter is invoked for your application, secrets will be injected prior to your application being run:

```sh
ruby app.rb

[doppler-env]: DOPPLER_ENV environment variable set. Fetching secrets using Doppler CLI.
[doppler-env]: Secrets loaded successfully:
[doppler-env]:   {"DOPPLER_CONFIG"=>"dev", "DOPPLER_ENVIRONMENT"=>"dev", "DOPPLER_PROJECT"=>"example"}
```

In restrictive environments where the use of the Doppler CLI isn't possible, set a `DOPPLER_TOKEN` environment variable with a [Service Token](https://docs.doppler.com/docs/service-tokens) to fetch secrets directly from the Doppler API:


```sh
ruby app.rb

[doppler-env]: DOPPLER_TOKEN environment variable set. Fetching secrets from Doppler API.
[doppler-env]: Secrets loaded successfully:
[doppler-env]:   {"DOPPLER_CONFIG"=>"dev", "DOPPLER_ENVIRONMENT"=>"dev", "DOPPLER_PROJECT"=>"example"}
```

## Acknowledgements

This approach to injecting environment variables was inspired by [dotenv](https://github.com/bkeepers/dotenv).

## Issues

For any bug reports, issues, or enhancements, please [create a repository issue](https://github.com/DopplerHQ/ruby-doppler-env/issues/new).

# Support

You can get support in the [Doppler community forum](https://community.doppler.com/), find us on [Twitter](https://twitter.com/doppler), and for bugs or feature requests, [create an issue](https://github.com/DopplerHQ/ruby-doppler-env/issues/new) on the [DopplerHQ/ruby-doppler-env](https://github.com/DopplerHQ/ruby-doppler-env) GitHub repository.

If you need help, either use our in-product support or head over to the [Doppler Community Forum](https://community.doppler.com/) to get your questions answered by a member of the Doppler support team or 
