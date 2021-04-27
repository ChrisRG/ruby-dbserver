require 'net/http'
require 'uri'

def random_set(iterations)
  iterations.times do
    name = ('a'..'z').to_a.sample
    num = rand(1..100)
    uri = URI.parse("http://localhost:4000/set?#{name}=#{num}")
    response = Net::HTTP.get(uri)
    p response
  end
end

def random_get(iterations)
  iterations.times do
    name = ('a'..'z').to_a.sample
    uri = URI.parse("http://localhost:4000/get?key=#{name}")
    response = Net::HTTP.get(uri)
    p response
  end
end

if ARGV.length >= 1
  if ARGV.include?('--set')
    puts "How many to randomly set?"
    iterations = STDIN.gets.chomp.to_i
    random_set(iterations)
  end
  if ARGV.include?('--get')
    puts "How many to randomly try to get?"
    iterations = STDIN.gets.chomp.to_i
    random_get(iterations)
  end
else
  puts "Too few arguments, use --set and/or --get"
end
