# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: hello.proto

require 'google/protobuf'


descriptor_data = "\n\x0bhello.proto\x12\x07\x65xample\"\x1e\n\x0e\x45xampleRequest\x12\x0c\n\x04name\x18\x01 \x01(\t\"\"\n\x0f\x45xampleResponse\x12\x0f\n\x07message\x18\x01 \x01(\t2S\n\x0e\x45xampleService\x12\x41\n\nGetExample\x12\x17.example.ExampleRequest\x1a\x18.example.ExampleResponse\"\x00\x62\x06proto3"

pool = Google::Protobuf::DescriptorPool.generated_pool
pool.add_serialized_file(descriptor_data)

module Example
  ExampleRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("example.ExampleRequest").msgclass
  ExampleResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("example.ExampleResponse").msgclass
end