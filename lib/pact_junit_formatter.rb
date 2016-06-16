require 'time'
require 'builder'

require 'rspec/core'
require 'rspec/core/formatters/base_formatter'

require 'pact_junit_formatter/version'

class PactJUnitFormatter < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register(self, :dump_summary)

  def dump_summary(notification)
    @notification = notification
    examples = rearrange(notification.examples.map {|e| PactExample.new(e) })
    xml_dump(examples)
  end

  private

  def rearrange(examples)
    examples.inject(Hash.new {|h, k| h[k] = [] }) do |h, example|
      h[example.package_name] << example
      h
    end
  end

  def xml_dump(examples)
    xml = Builder::XmlMarkup.new target: output, indent: 2
    xml.instruct!
    xml.testsuites(tests: @notification.examples.size, failures: @notification.failed_examples.size, time: @notification.duration) do
      examples.each {|package_name, es| dump_testsuite(xml, package_name, es) }
    end
  end

  def dump_testsuite(xml, package_name, es)
    failure_count = es.select {|e| e.status == :failed }.size
    duration = es.map {|e| e.run_time }.inject(0, &:+)
    timestamp = es.map {|e| e.started_at }.sort.first.iso8601

    xml.testsuite(name: package_name, tests: es.size, failures: failure_count, time: '%.6f' % duration, timestamp: timestamp) do
      xml.properties
      es.each {|e| ExampleDumper.new(xml, e).call }
    end
  end

  class ExampleDumper
    def initialize(xml, example)
      @xml = xml
      @example = example
    end

    def call
      case @example.status
      when :passed
        dump_example(@example)
      when :pending
        dump_pending(@example)
      when :failed
        dump_failed(@example)
      else
        raise "Unexpected example status: #{@example.status}"
      end
    end

    private

    def dump_pending(example)
      dump_example(example) { @xml.skipped }
    end

    def dump_failed(example)
      exception = example.example.execution_result.exception
      backtrace = example.example.formatted_backtrace

      dump_example(example) do
        @xml.failure(message: exception.to_s, type: exception.class.name) do
          @xml.cdata!("#{exception.message}\n#{backtrace.join("\n")}")
        end
      end
    end

    def dump_example(example, &block)
      @xml.testcase(
        classname: example.classname,
        name: example.description,
        file: '',
        time: "%.6f" % example.run_time,
        &block
      )
    end
  end

  class PactExample
    attr_reader :example, :contract
    def initialize(example)
      @example = example
      @contract = JSON.parse(example.metadata[:pact_json])
    end

    def consumer_name
      @contract['consumer']['name']
    end

    def provider_name
      @contract['provider']['name']
    end

    def interaction_name
      @example.metadata[:pact_interaction_example_description]
    end

    def description
      @example.full_description.match(/(returns\s+.+)\z/)[1]
    end

    def package_name
      "#{consumer_name}-#{provider_name}"
    end

    def classname
      "#{package_name}.#{interaction_name}"
    end

    def status
      @example.execution_result.status
    end

    def run_time
      @example.execution_result.run_time
    end

    def started_at
      @example.execution_result.started_at
    end
  end
end
