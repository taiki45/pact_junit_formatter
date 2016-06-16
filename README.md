# PactJunitFormatter
Generate a pact verification report with JUnit format.
Nice to see pact verification result in Jenkins Web UI.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pact_junit_formatter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pact_junit_formatter

## Usage
Define your pact verification task by using `Pact::VerificationTask`:

```ruby
require 'pact/tasks'
Pact::VerificationTask.new(:with_report) do |task|
  task.rspec_opts = '--format PactJUnitFormatter --out pact-verfication-report.xml'
  task.uri(nil) # Verify with all pact files
end
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
