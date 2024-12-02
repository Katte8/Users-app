require 'sqlite3'

class Users 
    # database connection
    DB = SQLite3::Database.new("db.sql")

    # Create a new user
    def self.create(user_info)
        # check if user already exists by email
        exsisting_user = DB.execute("SELECT * FROM users WHERE email = ?", user_info[:email])
        return if exsisting_user.any? # skip if user already exists
        # insert new user if not in the database
        DB.execute("INSERT INTO users (firstname, lastname, age, password, email)
        VALUES (?, ?, ?, ?, ?)",
        [user_info[:firstname], user_info[:lastname],
        user_info[:age], user_info[:password], user_info[:email]])
        DB.last_insert_row_id #return the ID of the newly created user
    end

    # Find a user by id
    def self.find(user_id)
        #execute the sql query to find the user by id
        result = DB.execute("SELECT * FROM users WHERE id = ?", user_id)
        #return the first user if found, otherwise return nil
        result.first
    end

    # Find all users in the database
    def self.all()
        #run the sql quert to fetch all rows and return the result
        rows =DB.execute("SELECT * FROM users")
    end

    # Update a user's information, attribute should be one of the allowed attributes: firstname, lastname, age, password, email
    def self.update(user_id, attribute, value)
        # validate the attribute to prevent sql injection
        allowed_attributes = ["firstname", "lastname", "age", "password", "email"]
        unless allowed_attributes.include?(attribute)
            raise "Invalid attribute: #{attribute}"
        end
        # execute the sql query to update the specified attribute
        query = "UPDATE users SET #{attribute} = ? WHERE id = ?"
        DB.execute(query, [value, user_id])
        #return the updated user
        find(user_id)
    end

    # Delete a user by id
    def self.delete(user_id)
        DB.execute("DELETE FROM users WHERE id = ?", user_id)
    end
end

# Debugging
# 1) For user creation in database
# user_info = { firstname: "Bob", lastname: "Vane", age: 30, password: "parole", email: "bobe@example.com" }
# user_id = Users.create(user_info)
# puts "User created with ID: #{user_id}"

# 2) Finding user
# user = Users.find(31)
# if user
#   puts "User found: #{user.join(' | ')}"
# else
#   puts "User not found."
# end

# 3) Get all users
# users = Users.all
# if users.any?
#     puts "Users found: #{users.map { |user| user.join(' | ') }.join("\n")}"
#   else
#     puts "No users found."
#   end

# 4) Updating user
# updated_user = Users.update(31, "password", "mynewpassword")
# puts "User updated: #{updated_user.join(' | ')}"

# 5) Deleting user
# Users.delete(31)
# puts "User deleted with ID: 31"
  



