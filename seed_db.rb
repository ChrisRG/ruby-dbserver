require 'net/http'
require 'uri'

def random_access(iterations, path)
  iterations.times do
    name = ('a'..'z').to_a.sample + ('a'..'z').to_a.sample # Random two-letter name
    if path == 'set' 
      num = rand(1..100)
      query = "#{name}=#{num}"
    elsif path == 'get'
      query = "key=#{name}"
    end
    uri = URI.parse("http://localhost:4000/#{path}?#{query}")
    response = Net::HTTP.get(uri)
    p response
  end
end

if ARGV.length >= 1
  if !ARGV.include?('--set') && !ARGV.include?('--get')
    puts 'Usage: ruby seed_db.rb --set | --get'
    return
  end
  if ARGV.include?('--set')
    puts "How many keys to randomly set?"
    iterations = STDIN.gets.chomp.to_i
    random_access(iterations, 'set')
  end
  if ARGV.include?('--get')
    puts "How many keys to randomly try to get?"
    iterations = STDIN.gets.chomp.to_i
    random_access(iterations, 'get')
  end
else
  puts "Too few arguments, use [--set | --get]"
end
