require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  @@all = []

  def initialize(hash, id = nil)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = id
    @@all << self
  end


  def self.all
    @@all
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs(
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
    # if self.id
    #   self.update
    # else
      sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES(?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    # end
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    self.all.find {|dog| dog.id == id }
    # sql = <<-SQL
    #   SELECT * FROM dogs WHERE id = ?
    # SQL
    #
    # DB[:conn].execute(sql, id)
  end


  def self.find_or_create_by(dog)
      sql = <<-SQL
        SELECT * FROM dogs  WHERE name = ? AND breed = ?
      SQL
      dog_list = DB[:conn].execute(sql, dog[:name], dog[:breed])
      if !dog_list.empty?
        dog_info = dog_list[0]
        doggo = Dog.new(dog, dog_info[0])
        doggo
      else
        doggie = Dog.new(dog)
        doggie.save
        doggie
      end
  end


  def self.new_from_db(input)
    hash={name: input[1],breed: input[2]}
    id = input[0]
    d1 = Dog.new(hash, id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL

    dog = DB[:conn].execute(sql, name)
    did = dog[0][0]
    dbreed = dog[0][2]
    self.all.find {|dog| dog.id == did && dog.breed == dbreed && dog.name == name }
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?,
      breed = ?
      WHERE
      id = ?
    SQL
     DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
