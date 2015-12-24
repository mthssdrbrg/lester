module Lester
  class NullLogger < ::Logger
    def initialize
      super(nil)
    end
  end

  class Logger < ::Logger
    def initialize(quiet=false, verbose=false, stdout=$stdout, stderr=$stderr)
      @stdout = create_logger(stdout, ::Logger::INFO)
      @stderr = create_logger(stderr, ::Logger::WARN)
      if quiet
        @stdout.level = ::Logger::FATAL
      elsif verbose
        @stdout.level = ::Logger::DEBUG
      end
      super(nil)
    end

    def create_logger(output, level)
      logger = ::Logger.new(output)
      logger.level = level
      logger.formatter = proc { |_, _, _, msg| msg + NEWLINE }
      logger
    end

    def add(severity, message=nil, progname=nil, &block)
      if severity <= ::Logger::INFO
        @stdout.add(severity, message, progname, &block)
      else
        @stderr.add(severity, message, progname, &block)
      end
    end

    private

    NEWLINE = "\n".freeze
  end
end
