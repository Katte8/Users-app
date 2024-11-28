require 'sinatra' # Loads the Sinatra framework to handle HTTP requests and routing. Sinatra provides methods like get, post, put, delete.
require 'sqlite3' # Loads the sglite3 gem to interact with a sqlite database (execute sql commands)
require 'sinatra/json' # Provides a method (json) to easily send JSON responses
require_relative 'my_user_model' # Loads the my_user_model file where Users class is defined. This class handles database interactions like retrieving, creating, deleting users.

enable :sessions # Enables session handling, allowing the server to track logged-in users across requests.
set :session_secret, '39d4c281906ada11816a7c4c50b33d009884a779eba4203ed1b5f36b3e52d2e2c57c10f203f3a7b29d2d711b0a8153fc01679616b765990256d5e5407806a76'
set :server, 'puma' # Specifies the Puma server, a faster alternative to sinatras default one.
set :views, './views' # This tells Sinatra where to look for the HTML files.
set :port, 8080 # This ensures that Sinatra app runs on port 8080. By default it would be 4567.
set :bind, '0.0.0.0' # This binds the app to all available network interfaces (0.0.0.0), making it accessible locally (e.g., localhost) and, if needed, on network.

# For debbuging purposes
# get '/test' do
#     "Puma and Sinatra are working!"
#   end

# For the III Part -> Add the GET route for /
# The @users variable is an instance variable, which makes it accessible in the view file (index.html.erb in this case).
get '/' do
    @users = Users.all.map do |user| 
      {
        firstname: user[1],
        lastname: user[2],
        age: user[3],
        email: user[5]
      }
    end
    erb :index # The erb method tells Sinatra to render an ERB template. In this case, :index refers to the file views/index.html.
end
  

# 1.GET on /users. This action will return all users (without their passwords).
  get '/users' do # When someone accesses /users (e.g., via a browser or API call), the code inside this block will execute.
    users = Users.all.map do |user| # Calls the Users.all method, which retrieves all users from the database. map iterates over each user record
        # Construct a new hash excluding the password. .reject method didn't work, so I had to create new hashes (also in tasks below)
    {
        id: user[0],
        firstname: user[1],
        lastname: user[2],
        age: user[3],
        email: user[5]
    }
    end  
    json users # Convert the users hash into JSON format and sends it as the response to the client.
end

# 2.POST on /users. Receiving firstname, lastname, age, password and email. It will create a user and store in your database and returns the user created (without password).
post '/users' do 
    # Extract data from the request parameters
    user_info = {
        firstname: params[:firstname], # params is a Sinatras object that contains the parameters sent with the request ->
        lastname: params[:lastname],   # -> If the request sends firstname=John, then params[:firstname] will be "John".
        age: params[:age],
        password: params[:password],
        email: params[:email]
    }

    # Create the user in the database
    user_id = Users.create(user_info) # Calls the create method in the Users class to insert the new user into the database.

    # Find the newly created user
    created_user = Users.find(user_id)

    # Format the user data into a hash, excluding the password
    user_hash = {
        id: created_user[0],
        firstname: created_user[1],
        lastname: created_user[2],
        age: created_user[3],
        email: created_user[5]
    }
    # Return the user data as JSON and sends it as a response
    json user_hash
end

# 3.This route is used to log in users. Once logged in, the session allows the server to remember the user during their
#interactions
post '/sign_in' do
    # Retrieve email and password from the request
    email = params[:email]
    password = params[:password]

    # Find the user in the Users class based on the provided email and password
    user = Users.all.find { |u| u[5] == email && u[4] == password } # u[5] refers to the email field; u[4] - password field.

    # If user is not found, return a 401 Unauthorized error
    halt 401, json({error: 'Invalid email or password'}) unless user

    # Store the user’s ID in the session to mark them as logged in.
    session[:user_id] = user[0]

    # Format the logged in users data into a hash (exclude password).
    response_user = {
        id: user[0],
        firstname: user[1],
        lastname: user[2],
        age: user[3],
        email: user[5]
    }
    # Return the logged-in user's data as JSON
    json response_user
end

# Debug route
# get '/session' do
#    session.inspect
# end

# 4. Receive a new password and update it in the database. The user must be logged in. Return the user created (without password).

put '/users' do
    # Check if the user is logged in (check if session[:user_id] is set). If not, return a 401  - Unauthorized response.
    halt 401, json({ error: 'Unauthorized'}) unless session[:user_id]

    # Get the new password from the request and validate that it’s not empty or nil.
    new_password = params[:password]
    halt 400, json({ error: 'Password is required'}) if new_password.nil? || new_password.empty?

    # Update the password in the database
    user_id = session[:user_id] #retrieve the currently logged-in user's ID from the session and assigns it to a local variable
    Users.update(user_id, "password", new_password)

    # Find the newly updates user
    updated_user = Users.find(user_id)

    # Format the updated users data into a hash (exclude password).
    response_user = {
        id: updated_user[0],
        firstname: updated_user[1],
        lastname: updated_user[2],
        age: updated_user[3],
        email: updated_user[5]
    }
    # Returns the updated user data as JSON
    json response_user
end

# 5.DELETE on /sign_out. This action require a user to be logged in. It will sign_out the current user. It returns nothing (code 204 in HTTP).
delete '/sign_out' do
    # Check if the user is logged in - check if session[:user_id] is set. If not, return a 401 Unauthorized response.
    halt 401, json({ error: 'Unauthorized'}) unless session[:user_id]
    
    # Clear all session data (logges out)
    session.clear
    response.set_cookie('rack.session', value: '', path: '/', expires: Time.at(0)) # Deletes the session cookie by setting its value to an empty string and its expiration time to the past.

    # Return an empty response with a status code of 204 (No Content)
    status 204
end

# 6.DELETE on /users. This action require a user to be logged in. It will sign_out the current user and it will destroy the current user. It returns nothing (code 204 in HTTP).
delete '/users' do
    # Check if the user is logged in - check if session[:user_id] is set. If not, return a 401 Unauthorized response.
    halt 401, json({ error: 'Unauthorized'}) unless session[:user_id]

    # Get the current user ID from the session
    user_id = session[:user_id]

    # Delete the user from the database
    Users.delete(user_id)

    # Clear the session and cookies (logges the user out)
    session.clear
    response.set_cookie('rack.session', value: '', path: '/', expires: Time.at(0))

    status 204
end




