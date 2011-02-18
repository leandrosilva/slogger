module Slogger
  module Rack
    #
    # Slogger::Rack::RequestLogger is a kind of Rack middleware. It forwards every
    # request to an +app+ given, and logs a line in the syslog using Slogger::Logger.
    #
    # Yes, it's based on Rack::CommonLogger code.
    #
    class RequestLogger
      FORMAT = %{%s - %s "%s %s%s %s" %d %s %0.4f}

      #
      # To build a Slogger::Rack::RequestLogger instance.
      #
      # +app+::     The Rack application
      # +logger+::  A Slogger::Logger instance
      #
      def initialize(app, slogger)
        @app = app
        @logger = slogger
      end

      def call(env)
        began_at = Time.now
        status, header, body = @app.call env
        header = ::Rack::Utils::HeaderHash.new header

        log env, status, header, began_at
      
        [status, header, body]
      end

      private

      def log(env, status, header, began_at)
        now = Time.now
        length = extract_content_length header

        message = FORMAT % [
          env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
          env["REMOTE_USER"] || "-",
          env["REQUEST_METHOD"],
          env["PATH_INFO"],
          env["QUERY_STRING"].empty? ? "" : "?#{env['QUERY_STRING']}",
          env["HTTP_VERSION"],
          status.to_s[0..3],
          length,
          now - began_at ]
        
        sanitize! message
      
        @logger.info message
      end

      def extract_content_length(headers)
        value = headers["Content-Length"] or return "-"
        value.to_s == "0" ? "-" : value
      end
    
      def sanitize!(string)
        string.gsub!("%", "%%")
      end
    end
  end
end
