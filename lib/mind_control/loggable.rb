# encoding: utf-8
require "logger"

module MindControl
  ##
  # Mixin for event logging.
  #
  module Loggable

    #
    # Add all logging methods from standard Logger class.
    #

    { :debug => Logger::Severity::DEBUG,
      :info  => Logger::Severity::INFO,
      :warn  => Logger::Severity::WARN,
      :error => Logger::Severity::ERROR,
      :fatal => Logger::Severity::FATAL }.each do |name, severity|

      ##
      # @param [String] message Event text.
      #
      define_method name do |message = nil, &block|
        raise ArgumentError, "block is missing" if !message && !block
        logger.add severity, message, facility, &block if logger # NB: log ONLY if logger is set
      end
    end

    private

    ##
    # Returns global logger.
    # @return [Logger, nil]
    #
    def logger
      MindControl.logger
    end

    ##
    # Returns log facility for current class: demodulized snake_cased class name.
    # @return [String]
    #
    def facility
      @facility ||= self.class.name.split( "::" ).last.gsub( /([a-z])([A-Z])/, "\\1_\\2" ).downcase
    end
  end
end