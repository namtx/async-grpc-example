require 'async'
require 'hello_services_pb'

module Handlers
  class HelloHandler < Example::ExampleService::Service
    def get_example(request, _call)
      sleep rand(1..5)
      Example::ExampleResponse.new(message: "Hello, #{request.name}!")
    end
  end
end
