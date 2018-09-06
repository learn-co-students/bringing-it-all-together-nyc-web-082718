class Dog
  attr_accessor :name, :breed, :id

  def initialize(args)
    @name = args[:name]
    @breed = args[:breed]
    @id = args[:id]
  end

######################

  def self.create(args)
    d = Dog.new(args)
    d.save
    d
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    info = {
      name: row[1],
      breed: row[2],
      id: row[0]
    }
    s = Dog.new(info)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    row = DB[:conn].execute(sql, name)[0]

    Dog.new_from_db(row)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    row = DB[:conn].execute(sql, id)[0]

    Dog.new_from_db(row)
  end

  def self.find_or_create_by(args)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND
            breed = ?
      LIMIT 1
    SQL
    rows = DB[:conn].execute(sql, args[:name], args[:breed])

    if !rows.empty?
      row = rows[0]
      Dog.new_from_db(row) #create ruby instance
    else
      Dog.create(args) #create ruby instance AND create database row
    end

  end

######################

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?,
          breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)

      rows = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")
      @id = rows[0][0]
    end
    self
  end



end
