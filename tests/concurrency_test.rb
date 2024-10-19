# test_concurrency.rb
lib_dir = File.expand_path(File.join(__dir__, '..', 'lib'))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'hello_services_pb'

# Method to send a single gRPC request
def send_request(name)
  stub = Example::ExampleService::Stub.new('0.0.0.0:50051', :this_channel_is_insecure)
  response = stub.get_example(Example::ExampleRequest.new(name:))
  puts "Greeting: #{response.message} from #{name} at #{Time.now}"
end

# Test method to check concurrency
def test_concurrent_requests
  start_time = Time.now
  puts "Starting concurrent requests at #{start_time}"

  # Run 5 requests concurrently using threads
  threads = []
  20.times do |i|
    threads << Thread.new do
      send_request("Client #{i}")
    end
  end

  # Wait for all threads to finish
  threads.each(&:join)

  end_time = Time.now
  puts "Finished all requests at #{end_time}"
  puts "Total time taken: #{end_time - start_time} seconds"
end

# Run the test
test_concurrent_requests
# send_request('test')
