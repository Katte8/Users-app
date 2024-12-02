# Welcome to My Users App
***

## Task
In this project, a simple user management system using Sinatra and SQLite3 is built. The system allows the creation, retrieval, update, and deletion of users, with session management implemented for user sign-in and sign-out.

This project follows the Model-View-Controller (MVC) architecture, where:
- Model: Handles the data and business logic (implemented using the `Users` class with methods to interact with the SQLite database).
- View: Provides the user interface (HTML view files).
- Controller: Manages requests, processes them using the Model, and returns responses (Sinatra routes).

## Description
The Users class serves as the model, handling the interaction with the SQLite3 database. It allows for:
- Creating new users.
- Retrieving individual users and all users.
- Updating user details, such as passwords.
- Deleting users from the database.

Controller: The application exposes several API endpoints to perform operations on users:
POST /users: Allows you to create new users by sending their details as form data.
GET /users: Fetches and returns all users as JSON.
PUT /users: Updates a user's details (e.g., changing the password).
DELETE /users: Deletes a user from the database.
POST /sign_in: Signs the user in, storing their user ID in the session.
DELETE /sign_out: Signs the user out and clears their session.
Session Management: The application uses cookies to maintain session states. When a user logs in, their user ID is stored in the session, allowing for restricted actions like updating or deleting a user.

## Installation
1. Clone the Repository**

   First, clone the repository to your local machine:

   ```bash
   git clone https://github.com/Katte8/Users-app.git

2. Navigate to the Project Directory

    Move into the project folder:
    cd Users-app

3. Install Dependencies

   Project requires installing the required gems. If you are using Bundler, follow these steps:

    - Install Bundler (if you don't have it installed already):
    gem install bundler

    - Install the gems
    bundle install

    - If you are not using Bundler, you can manually install the required gems by running:
    gem install sinatra sqlite3

## Usage
1. Start the Sinatra application: To start the server, run the following command in your terminal from the project directory:
ruby app.rb
This will start the application on http://localhost:8080.

2. Interact with the API: You can perform CRUD operations using curl commands.

- Create a new user (POST /users): Use the following curl command to create a new user:
curl -X POST -i http://localhost:8080/users -d "firstname=Luke" -d "lastname=Tinker" -d "age=34" -d "password=secret" -d "email=luke@example.com"
This will create a new user and return the user details (without the password).

- Get all users (GET /users): To get a list of all users in the database, use:
curl -i http://localhost:8080/users
This will return all users as a JSON response.

- Sign in a user (POST /sign_in): To sign in a user and start a session:
curl -X POST -i http://localhost:8080/sign_in -d "email=john@example.com" -d "password=secret"

- Update user information (PUT /users): To update the password of a user, use the following curl command (use your rack.session=A....; httponly):
curl -X PUT -i http://localhost:8080/users -d "password=newpassword" -b "rack.session=your_session_id"


- Sign out (DELETE /sign_out): To sign out the current user:
curl -X DELETE -i http://localhost:8080/sign_out -b "rack.session=your_session_id"

- Delete a user (DELETE /users): To delete a user, use (you have to be sing-in first):
curl -X DELETE -i http://localhost:8080/users -b "rack.session=your_session_id"

### The Core Team


<span><i>Made at <a href='https://qwasar.io'>Qwasar SV -- Software Engineering School</a></i></span>
<span><img alt='Qwasar SV -- Software Engineering School's Logo' src='https://storage.googleapis.com/qwasar-public/qwasar-logo_50x50.png' width='20px' /></span>
