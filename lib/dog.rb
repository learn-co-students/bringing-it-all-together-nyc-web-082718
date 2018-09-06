require 'pry'

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
  sql = <<-SQL
  DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE dogs SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.id, self.name, self.breed)
  end

  def save
      if self.id
        self.update
      else
        sql = <<-SQL
          INSERT INTO dogs(name, breed)
          VALUES (? , ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id:id, name:name, breed:breed)
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    LIMIT 1
    SQL
    DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    LIMIT 1
    SQL

    x = DB[:conn].execute(sql, name).first
    self.new_from_db(x)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
    if !(dog.empty?)
      dog_info = dog[0]
      dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    else
      dog = self.create(name:name, breed:breed)
    end
    dog
  end


end
