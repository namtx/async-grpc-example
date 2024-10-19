# frozen_string_literal: true

# modify $LOAD_PATH to include the lib directory
lib_dir = File.expand_path(File.join(__dir__, '..', 'lib'))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'async'
require 'async/http/protocol/http2'
require 'async/http/endpoint'
require 'async/http/server'
require 'async/semaphore'
require 'async/http/protocol/response'
require 'protocol/http2'
require 'hello_services_pb'
require_relative './handlers/hello_handler'

# GrpcServer class to handle incoming gRPC requests
class GrpcServer
  def run(request)
    puts Thread.current.object_id
    example_request = protobuf_decode(request.body.read, Example::ExampleRequest)

    response = Async do
      Handlers::HelloHandler.new.get_example(example_request, nil)
    end.wait

    response_body = protobuf_encode(response)
    request.stream.send_headers(nil, [
                                  [':status', '200'],
                                  ['content-type', 'application/grpc'],
                                  ['grpc-accept-encoding', 'identity,deflate,gzip'],
                                  ['accept-encoding', 'identity,gzip']
                                ])
    max_frame_size = request.stream.maximum_frame_size
    io = StringIO.new(response_body)
    until io.eof?
      chunk = io.read(max_frame_size)
      data_frame = Protocol::HTTP2::DataFrame.new(request.stream.id)
      data_frame.pack(chunk)
      request.stream.write_frame(data_frame)
    end
    Async::HTTP::Protocol::Response[200, { 'grpc-status': '0', 'grpc-message' => 'OK' }, nil]
  end

  private

  def protobuf_decode(data, protobuf_message_klass)
    compressed_flag = data[0].unpack1('C')
    raise 'Compressed gRPC  messages are not supported' if compressed_flag != 0

    message_length = data[1, 4].unpack1('N')

    protobuf_message = data[5, message_length]

    protobuf_message_klass.decode(protobuf_message)
  end

  def protobuf_encode(message)
    encoded_message = message.class.encode(message)
    message_length = [encoded_message.bytesize].pack('N')
    compressed_flag = [0].pack('C')
    compressed_flag + message_length + encoded_message
  end
end

Async do
  endpoint = Async::HTTP::Endpoint.parse('http://0.0.0.0:50051', protocol: Async::HTTP::Protocol::HTTP2)

  server = Async::HTTP::Server.for(endpoint) do |request|
    GrpcServer.new.run(request)
  end
  server.run
end
