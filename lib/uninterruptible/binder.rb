require 'uri'

module Uninterruptible
  class Binder
    attr_reader :bind_uri

    # @param [String] bind_address The config for a server we're returning the socket for
    #   @example
    #     "unix:///tmp/server.sock"
    #     "tcp://127.0.0.1:8080"
    def initialize(bind_address)
      @bind_uri = parse_bind_address(bind_address)
    end

    # Bind to the TCP or UNIX socket defined in the #bind_uri
    #
    # @return [TCPServer, UNIXServer] Successfully bound server
    #
    # @raise [Uninterruptible::ConfigurationError] Raised when the URI indicates a non-tcp or unix scheme
    def bind_to_socket
      case bind_uri.scheme
      when 'tcp'
        bind_to_tcp_socket
      when 'unix'
        bind_to_unix_socket
      else
        raise Uninterruptible::ConfigurationError, "Can only bind to TCP and UNIX sockets"
      end
    end

    private

    # Connect (or reconnect if the FD is set) to a TCP server
    #
    # @return [TCPServer] Socket server for the configured address and port
    def bind_to_tcp_socket
      if ENV[SERVER_FD_VAR]
        TCPServer.for_fd(ENV[SERVER_FD_VAR].to_i)
      else
        TCPServer.new(bind_uri.host, bind_uri.port)
      end
    end

    # Connect (or reconnect if FD is set) to a UNIX socket. Will delete existing socket at path if required.
    #
    # @return [UNIXServer] Socket server for the configured path
    def bind_to_unix_socket
      if ENV[SERVER_FD_VAR]
        UNIXServer.for_fd(ENV[SERVER_FD_VAR].to_i)
      else
        File.delete(bind_uri.path) if File.exist?(bind_uri.path)
        UNIXServer.new(bind_uri.path)
      end
    end

    # Parse the bind address in the configuration
    #
    # @param [String] bind_address The config for a server we're returning the socket for
    #
    # @return [URI::Generic] Parsed version of the bind_address
    #
    # @raise [Uninterruptible::ConfigurationError] Raised if the bind_address could not be parsed
    def parse_bind_address(bind_address)
      URI.parse(bind_address)
    rescue URI::Error
      raise Uninterruptible::ConfigurationError, "Couldn't parse the bind address: \"#{bind_address}\""
    end
  end
end
