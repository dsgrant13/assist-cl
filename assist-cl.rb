#Test ruby script for getting information from websites
#Goal: emulate assist.org
#ask user for current school, desired school, and major and save the agreement as a .txt file

require 'net/http'
require 'io/console'

school_keys = IO.readlines("school_keys.txt")
school_values = IO.readlines("school_values.txt")
schools = Hash.new
for i in 0...school_keys.length do
  school_keys[i] = school_keys[i][0, school_keys[i].length-2]
  school_values[i] = school_values[i][0, school_values[i].length-1]
  schools[school_keys[i]] = school_values[i]
end
schools.each { |from, to| puts "#{from}: #{to}" }

puts "Where do you go to school currently?"
from = schools[gets.chomp]
puts from
puts "What school would you like to transfer to?"
to = schools[gets.chomp]
puts to
puts "What is your major?"
major = schools[gets]

uri = URI("http://web1.assist.org/cgi-bin/REPORT_2/Rep2.pl?aay=13-14&dora=ECON&oia=#{to}&ay=14-15&event=19&ria=#{to}&agreement=aa&sia=#{from}&ia=#{from}&dir=1&&sidebar=false&rinst=left&mver=2&kind=5&dt=2")

agreement = Net::HTTP.get(uri)

f = File.open("agreement.txt", 'w+') { |f| f.write(agreement) }
lines = IO.readlines("agreement.txt")

def no_symbols?(line)
  !line.include? '<' and !line.include? '-' and !line.include? ' ' and !line.include? '(' and !line.include? ';'
end

lines_that_matter = []
title = "From: #{from}, To: #{to}, Major: #{major} \n"
lines_that_matter.push(title)

#set the first line to '-'s to look pretty
lines.each do |line|
  if line[0..4] == '-----'
    lines_that_matter.push(line)
    break
  end
end

i = 0
lines.each do |line|
  i += 1
  if line[0..3] == line[0..3].upcase and no_symbols?(line[0..3]) and line[0] != "\n" and line.include? '|'
    lines_that_matter.push(line)
    j = i
    until lines[j][0..4] == '-----' do
      lines_that_matter.push(lines[j]) unless i==1
      j += 1
    end
    lines_that_matter.push(lines[j])
  end
end

def bracket?(char)
  char == '<' or char == '>'
end

def remove_html(line)
  if line.include? '<'
    no_html = ''
    dont_add = false
    for i in 0...line.length do
      dont_add = true if line[i] == '<'
      no_html += line[i] unless bracket?(line[i]) or dont_add
      dont_add = false if line[i] == '>'
    end
    return no_html
  else
    return line
  end
end

lines.each do |line|
  line = remove_html(line)
  puts line
end

File.open("agreement.txt", "w") { |file| file.truncate(0) } #hopefully this clears the text file 

f = File.open("agreement.txt", 'w') do |f|
  lines.each do |line|
    line = remove_html(line)
    f.write(line)
  end
end

