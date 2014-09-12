#schools.rb
#Just a short script to create the text files for creating
#the Hash that will map school names to their html names
#used by Assist

require 'rubygems'
require 'nokogiri'
require 'open-uri'

page = Nokogiri::HTML(open('http://www.assist.org/web-assist/welcome.html'))
lines = IO.readlines("school_keys.txt")

schools = Hash.new
page.css('option').each do |school|
  value = school['value']
  if value != ""
    schools[school.text] = value[0...value.length-5]
  end
end

schools.each { |school, value| puts "#{school} => #{value}"}




