# Holistics CLI

[![Gem Version](https://badge.fury.io/rb/holistics-cli.svg)](https://badge.fury.io/rb/holistics-cli) [![Test Coverage](https://codeclimate.com/github/pmint93/holistics-cli/badges/coverage.svg)](https://codeclimate.com/github/pmint93/holistics-cli/coverage) [![Code Climate](https://codeclimate.com/github/pmint93/holistics-cli/badges/gpa.svg)](https://codeclimate.com/github/pmint93/holistics-cli)

CommandLine Interface for [Holistics API](https://docs.holistics.io/api/)

> Disclaim: The official Holistics CLI is quite limit for me, so I made this gem as an alternative.

> Also, this offer some commands that's not yet documented by Holistics or implemented in official CLI.

## Installation

    $ gem install holistics-cli
    

:warning: This gem use the same command `holistics` as [Official Holistics-CLI](https://docs.holistics.io/holistics-cli/), so it may confict if both installed.

## Usage

```
$ holistics
Commands:
  holistics config [TOKEN]  # Init or update config
  holistics help [COMMAND]  # Describe available commands or one specific command
  holistics imports         # Import jobs
  holistics jobs            # Submitted jobs
  holistics sources         # Data sources
  holistics transforms      # Data transformations
  holistics version         # Show version information
```

Learn more by help command: `holistics help`


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pmint93/holistics-cli. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Holistics-CLI project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pmint93/holistics-cli/blob/master/CODE_OF_CONDUCT.md).

## Related

* [Official Holistics CLI](https://docs.holistics.io/holistics-cli/)
