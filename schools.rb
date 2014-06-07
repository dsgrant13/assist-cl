#schools.rb
#Just a short script to create the text files for creating
#the Hash that will map school names to their html names
#used by Assist

require 'net/http'
require 'io/console'

def isCollegeLine(line)
  line.include? '<!--' and !line.include? '<a' \
  and (line.include? 'College' or line.include? 'UC' or \
  line.include? 'CSU' or line.include? 'State')
end

uri = URI('http://www.assist.org/web-assist/welcome.html')
schools = Net::HTTP.get(uri)
File.open("school_keys.txt", "w+") { |f| f.write(schools) }
lines = IO.readlines("school_keys.txt")

school_lines = []
for i in 0...lines.length do
  if isCollegeLine(lines[i])
    school_lines.push(lines[i]) #all title lines are even
    school_lines.push(lines[i+1]) #all lines with html name odd
  end
end

def extract_title(line)
  title = ''
  for i in 0...line.length do
    title += line[i] unless line[i] == ' ' or line[i] == "\n" \
             or line[i] == '<' or line[i] == '-' \
             or line[i] == '!' or line[i] == '>'
  end
  title = title.split /(?=[A-Z])/
  final = ''
  title.each { |word| final += "#{word} " }
  final = final[0, final.length-1]
  if final.include? "C S U"
    final = "CSU " + final[6, final.length-1]
  end
  if final == "U C L A"
    final = "UCLA"
  end
  if final.include? "U C D "
    final = "UCD " + final[6, final.length-1]
  end
  if final.include? "U C S F"
    final = "UCSF " + final[8, final.length-1]
  end
  if final.include? "U C" and !final.include? "CSU C"
    final = "UC " + final[4, final.length-1]
  end
  final = final.split(' ')
  for i in 0...final.length do
    final[i] = 'College of the' if final[i] == 'Collegeofthe'
    final[i] = 'College of' if final[i] == 'Collegeof'
    final[i] = 'School of' if final[i] == 'Schoolof'
  end
  real_final = ''
  final.each { |word| real_final += "#{word} " }
  return real_final
end

def extract_html(line)
  html = ''
  for i in 1...line.length
    next unless line[i] == line[i].upcase and line[i-1] == "\"" \
                and line[i] != ' '
    j = i
    until line[j] == "."
      html += line[j] unless line[j].nil?
      j += 1
    end
    return html
  end
end
      

File.open("school_keys.txt", "w") { |file| file.truncate(0) }
f1 = File.open("school_values.txt", "w")
f = File.open("school_keys.txt", 'w')
for i in 0...school_lines.length-1 do 
  title = extract_title(school_lines[i])
  html = extract_html(school_lines[i+1])
  if i % 2 == 0
    f.write(title+"\n")
    f1.write(html+"\n")
    puts "#{title} => #{html}"
  else
    #puts school_lines[i]
  end
end
