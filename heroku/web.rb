require 'sinatra'

$data = {}

get '/' do
  if params["set"]
    $data[params["set"]] = "yes"
  elsif params["get"]
    $data[params["get"]] ? "yes" : "no"
  elsif params["inspect"]
    $data.inspect
  else
    "Hello, world"
  end
end
