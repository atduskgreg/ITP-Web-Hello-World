### This Sinatra script takes a GET request from the web, 
###  stores values for x and y, and then returns all the 
###  stored x,y pairs it knows about, one per line

# load up the ruby libraries
require 'rubygems'
require 'sinatra'
require 'dm-core'

# configure your app to store data as yaml files in db/
DataMapper.setup(:default, ENV['DATABASE_URL'] || {:adapter => 'yaml', :path => 'db'})
### define a Rectangle class 
### Each line defines the name of the data to be stored, 
###   and a type for the value

class Rectangle
  include DataMapper::Resource   

  property :id,     Serial
  property :x,      Integer
  property :y,      Integer
end

# Define a route for the webserver for a get request
get "/returnRectangles" do

  # create an instance of the Rectangle class
  rectangle = Rectangle.new
  
  # set each attribute from the URL (available as a hash called 'params')
  
  rectangle.x = params[:x] 
  rectangle.y = params[:y]

  # Save the rectangle object to the database/file
  # This will save the object ID, plus x and y
  rectangle.save
  
  # Now read the stored data and return a list of all x,y pairs
  # Define a string for storing the output
  output = ""
  
  # Loop through all available data in Rectangle
  for r in Rectangle.all
    # This is a "here" document. It appends everything between 
    # <<-HTML and HTML into output
    output += <<-HTML
#{r.x},#{r.y}
HTML
  end
  # Send output back out as a response to the web request
  output
end

get "/clearRectangles" do
  for rectangle in Rectangle.all
    rectangle.destroy
  end
  "deleted all rectangles"
end


# display the web form for creating a rectangle
get "/newRectangle" do
  output = ""
  
  # we're going to submit the form to the same URL
  # as from Processing using the same verb
  output += '<form action="/returnRectangles" method="GET">'
  
  # the 'name' of the input translates into where the variable
  # ends up in the params in our other action
  # an input with name="x" becomes params[:x]
  output += '<p><label>x:</label> <input type="text" name="x" /></p>'
  output += '<p><label>y:</label> <input type="text" name="y" /></p>'
  
  # an input of type "submit" becomes a submit button for sending
  # in the form
  output += '<p><input type="submit" value="create" /></p>'
  output += '</form>'
  output
end
