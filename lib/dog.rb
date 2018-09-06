require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(id=nil, attributes)
    attributes.each { |key, value| self.send(("#{key}="), value)}
    @id = id
    # binding.pry
  end

  # def initialize(id=nil, name:, breed:)
  #   @id = id
  #   @name = name
  #   @breed = breed
  #   # binding.pry
  # end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    dog
  end

  def self.new_from_db(row)
    hash = {name: row[1], breed: row[2]}
    Dog.new(id = row[0], hash)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    Dog.new_from_db(row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    attributes = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(attributes)
    # binding.pry
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id= ?
    SQL
    # binding.pry
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    # binding.pry
  end

  def self.find_or_create_by(attributes)
    # binding.pry
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL
    # binding.pry
    if DB[:conn].execute(sql, attributes[:name], attributes[:breed])[0]
      DB[:conn].execute(sql, attributes[:name], attributes[:breed]).map do |row|
        # binding.pry
        self.new_from_db(row)
      end.first
    else
      sql2 = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      Dog.create(attributes)
      # binding.pry
    end
  end

end
