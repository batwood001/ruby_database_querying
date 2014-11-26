# After creating classmates_db
# 
require 'pg'

class Classmate
  
  def initialize
    @conn = PG::Connection.open(:dbname => 'classmates_db')
  end

  def create_tables
    sql = "CREATE TABLE classmates(first_name VARCHAR, last_name VARCHAR, twitter_handle VARCHAR, age INTEGER)"
    @conn.exec(sql)
  end


  def get_input(conn)
    another = true
    while another == true
      puts "First name?"
      first_name = gets.chomp
      puts "Last name?"
      last_name = gets.chomp
      puts "Twitter handle?"
      twitter_handle = gets.chomp
      puts "Age?"
      age = gets.chomp
      @conn.exec("INSERT INTO classmates (first_name, last_name, twitter_handle, age) VALUES ('#{first_name}', '#{last_name}', '#{twitter_handle}', #{age})")
      puts "Do you want to make another entry? Y or N"
      ans = gets.chomp
      if ans != "Y"
        another = false
      end
    end
  end

  def insert_into_table(first, last, twitter, age) #NICK's, similar to above (get_input)
    sql = %q[
      INSERT INTO classmates (first_name, last_name, twitter_handle, age)
      VALUES ($1, $2, $3, $4)
    ]
    @conn.exec_params(sql, [first, last, twitter, age])
  end

  def view_records(conn)
    results = conn.exec("SELECT * FROM classmates")
    results.entries.each do |x|
      puts "#{x["first_name"]}, #{x["last_name"]}, #{x["twitter_handle"]}, #{x["age"]}"
    end
  end

  def view_classmates #NICK'S, similar to above (view_records)
    sql = 'SELECT * FROM classmates'
    result = @conn.exec(sql)
    result.entries
  end

  def delete_record(conn, first_name, last_name)
    conn.exec("DELETE FROM classmates WHERE first_name='#{first_name}' AND last_name='#{last_name}'")
  end

  def delete_a_record(id) #NICK's, similar to above
    sql = %q[
      DELETE FROM classmates WHERE id = $1
    ]

    result = @conn.exec_params(sql, [id])
    result.entries
  end

  def update_record(conn)
    puts "Which record do you want to update?"
    names = conn.exec("SELECT first_name, last_name FROM classmates")
    names.each do |x|
      puts "#{x["first_name"]} #{x["last_name"]}"
    end

    puts "First Name:"
    firstname = gets.chomp
    puts "Last Name:"
    lastname = gets.chomp
    puts "Which parameter do you want to update?"
    to_update = gets.chomp
      unless (to_update == "first_name" or to_update == "last_name" or to_update == "twitter_handle" or to_update == "age")
        puts "Not a valid entry!"
      else
        puts "What do you want the new value to be?"
        newval = gets.chomp
        conn.exec("UPDATE classmates SET #{to_update}='#{newval}' WHERE first_name='#{firstname}' AND last_name='#{lastname}'")
      end
  end

  def update(id, opts={})
    columns = opts.keys
    values = opts.values

    columns = columns.join(',')
    values = values.join(',')

    sql = %q[
      UPDATE classmates SET ($1) = ($2)
    ]
    
    result = @conn.exec_params(sql, [columns, values])
  end

end

class CLI
  def self.command_list
    puts "Command list:"
    puts "1. add a record"
    puts "2. view all records"
    puts "3. update a record"
    puts "4. delete a record"
  end

  def self.start
    command_list
    @connection = Classmates.new

    print "==>"
    input = gets.chomp
    case input
    when 1
      add_record(input)
    when 2
      view_records(input)
    when 3
      update_record(input)
    when 4
      delete_record(input)
    when 5
      return
    end
  end

# 1 Brian Atwood 26 @batwood
  def self.add_record(input)
    pieces = input.split
    first = input[1]
    last = input[2]
    twitter = input[3]
    age = input[4]

    @connection.insert_into_table(first, last, twitter, age)
  end

end
