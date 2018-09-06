require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(h={}, id = nil)
    @name = h[:name]
    @breed = h[:breed]
    @id = id
  end

  def self.create_table
    sql = "CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.create(h={})
    dog = self.new(h)
    dog.save
    dog
  end

  def self.new_from_db(row)
    dog = self.new({name: row[1], breed: row[2]}, row[0])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    dog = DB[:conn].execute(sql, name)[0]
    self.new_from_db(dog)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    dog = DB[:conn].execute(sql, id)[0]
    self.new_from_db(dog)
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    found = DB[:conn].execute(sql, name, breed)
    if found.empty?
      dog = self.create(name: name, breed: breed)
    else
      doggo = found[0]
      dog = Dog.new({name: doggo[1], breed: doggo[2]}, doggo[0])
    end
    dog
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      dog = DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end

  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
