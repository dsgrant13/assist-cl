#assist-cl.rb

require 'nokogiri'
require 'open-uri'

welcome_page = Nokogiri::HTML(open('http://www.assist.org/web-assist/welcome.html'))

schools = Hash.new

welcome_page.css('option').each do |school|
  value = school['value']
  if value != ""
    schools[school.text] = value[0...value.length-5]
  end
end

schools.each { |school, value| puts "#{school} => #{value}" }

puts "Where do you go to school currently?"
from = schools[gets.chomp]
puts "Where do you want to transfer to?"
input = gets.chomp
if input.include? 'UC'
  input.gsub!('UC', 'University of California,')
end
if input.include? 'CSU'
  input.gsub!('CSU', 'California State University,')
end
to = schools[input]
puts "What is your major?"
major_name = gets.chomp

#Retrieve 'To' school's list of majors
school_page = Nokogiri::HTML(open("http://web1.assist.org/web-assist/articulationAgreement.do?inst1=none&inst2=none&ia=#{from}&ay=14-15&oia=#{to}&dir=1"))

major_form = nil
school_page.css('form').each do |form|
  major_form = form if form["name"] == 'major'
end

majors = Hash.new
major_form.css('option').each do |major|
  if major.text.include? major_name
    if !major["value"].include? " "
      majors[major.text] = major["value"]
    else
      value = major["value"].gsub(' ', '%20')
      majors[major.text] = value
    end
  end
end

major_list, i = [], 1
majors.each do |major, value| 
  puts "#{i}) #{major}"
  major_list.push(value)
  i += 1
end

puts "Please enter the number of the corresponding major above:"
major = major_list[gets.chomp.to_i - 1]

page = Nokogiri::HTML(open("http://web1.assist.org/cgi-bin/REPORT_2/Rep2.pl?aay=13-14&dora=#{major}&oia=#{to}&ay=14-15&event=19&ria=#{to}&agreement=aa&ia=#{from}&sia=#{from}&dir=1&&sidebar=false&rinst=left&mver=2&kind=5&dt=2"))

agreement = page.css('body').text
f = File.open("agreement.txt", 'w+') { |f| f.write(agreement) }

#Reminder: Code below is just practice with scan and regex
#Find a regex to match class title and use scan to get array of all classes

def getCourseNums(agreement)
  agreement.scan(/[A-Z]{3,8} [\d]{1,3}[A-Z]*/)
end

puts agreement
course_nums = getCourseNums(agreement)
course_nums.each { |course| puts course }
