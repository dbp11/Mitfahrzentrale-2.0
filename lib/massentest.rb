# encoding: utf-8
# Massentest für die Datenbank, d.h. hier werden die dafür benötigten Daten erstellt
require "bla"
require "bing/route"

#Anzahl der zu erstellenden Entities
anzusers = 100
anztrips = 200
anzcars = 120
anzrequests = 200
anzratings = 150
anzpassenger = 200

#Erstellen von  Users
x=0
users=[]
puts "User Erstellen"
until x==anzusers
  x=x+1
  puts "User "+x.to_s
  plz=@city_array[rand(2055)]
  u=User.new :email => "Test"+x.to_s+"@uos.com", :password => "dkruempe",:password_confirmation => "dkruempe", :name => "Dominik Krümpelmann", :user_type => true, :sex => true, :address => plz, :addressN => "effse", :addressE => "fsefsf", :zipcode => 12132, :phone => "054571598"+x.to_s, :instantmessenger => "icq: 5465465"+x.to_s, :city => "Hopsten", :email_notifications => true, :visible_phone => true, :visible_email => true, :visible_address => true, :visible_age => true, :visible_im => true, :visible_cars => true, :birthday => Date.new(1989,12,28), :visible_zip => true, :user_type => false, :visible_city => true, :business => false, :last_delivery => Time.now, :last_ratings => Time.now, :role => "member"
  users << u
end

#Erstellen von  Cars
x=0
cars=[]
puts "Cars Erstellen"
until x==anzcars
  x=x+1
  puts "Cars "+x.to_s
    c= Car.new :user_id => (rand(anzusers+1)), :seats => 5, :licence => "10234"+x.to_s, :price_km => 5.5, :smoker => true, :description => "Kein Kofferraum", :car_type => "BMW"
  cars << c
end

#Erstellen von  Trips
x=0
trips=[]
puts "Trips Erstellen"
until x>=anztrips
  begin
    x=x+1
    puts "Trips "+x.to_s
    user_id = (rand(anzusers)+1)
    car_id = (rand(anzcars)+1)
    #start_koordinaten
    begin
      plz_start = @city_array[rand(2055)]
      start=Geocoder.coordinates(plz_start.to_s)
    end while(start.nil?)
    #end_koordinaten
    begin
      plz_ende = @city_array[rand(2055)]
      ende = Geocoder.coordinates(plz_ende.to_s)
    end while (ende.nil? or (ende[0]==start[0]and ende[1]==start[1]))
    puts "START:" + plz_start.to_s + " ENDE:" + plz_ende.to_s
    puts "START CORD:" + start[0].to_s + " " + start[1].to_s
    puts "END CORD:" + ende[0].to_s + " " + ende[1].to_s
    t=Trip.new :user_id => user_id, :car_id => car_id, :starts_at_N => start[0].to_f, :starts_at_E => start[1].to_f, :ends_at_E => ende[1].to_f, :ends_at_N => ende[0].to_f, :start_zipcode => plz_start, :end_zipcode => plz_ende, :start_time => Time.now+1.day, :comment => "Biete eine Fahrt an!", :baggage => true, :free_seats => 4
    t.set_address_info
    sleep(0.5)
    puts t.start_street + ", " + t.start_zipcode.to_s + " " + t.start_city
    puts t.end_street + ", " + t.end_zipcode.to_s + " " + t.end_city
    route = Bing::Route.find(:waypoints => [t.start_street+", "+t.start_zipcode.to_s + " " + t.start_city,t.end_street+", "+t.end_zipcode.to_s+" "+t.end_city])[0]
      t.distance = route.total_distance
      t.duration = route.total_duration
    t.set_route
    trips << t
  rescue
    x=x-1
    retry
  end
end

#Erstellen von  Requests
x=0
requests=[]
puts "Requests Erstellen"
until x==anzrequests
  begin
  x=x+1
  puts "Request "+x.to_s
  user_id = rand(anzusers)
  #start_koordinaten
  begin
    plz_start = @city_array[rand(2055)]
    start=Geocoder.coordinates(plz_start.to_s)
  end while(start.nil?)
  #end_koordinaten
  begin
    plz_ende = @city_array[rand(2055)]
    ende = Geocoder.coordinates(plz_ende.to_s) 
  end while (ende.nil? or (ende[0]==start[0]and ende[1]==start[1]))
    puts "START:" + plz_start.to_s + " ENDE:" + plz_ende.to_s
    puts "START CORD:" + start[0].to_s + " " + start[1].to_s
    puts "END CORD:" + ende[0].to_s + " " + ende[1].to_s
  r = Request.new :starts_at_N => start[0].to_f, :starts_at_E => start[1].to_f, :ends_at_N => ende[0].to_f, :ends_at_E => ende[1].to_f, :start_zipcode => plz_start, :end_zipcode => plz_ende, :start_time => Time.now+1.day, :end_time => Time.now+365.day, :baggage => true, :comment => "Hilfe", :user_id => user_id, :start_radius => rand(51), :end_radius => rand(51)
  r.set_address_info
  sleep(0.5)
  puts t.start_street + ", " + t.start_zipcode.to_s + " " + t.start_city
  puts t.end_street + ", " + t.end_zipcode.to_s + " " + t.end_city
  route = Bing::Route.find(:waypoints => [r.start_street+", "+r.start_zipcode.to_s+" "+r.start_city,r.end_street+", "+r.end_zipcode.to_s+" "+r.end_city])[0]
    r.distance = route.total_distance
    r.duration = route.total_duration
  r.set_route
  requests << r
  rescue
    x=x-1
    retry
  end
end


#Erstellen der Daten
users.each  do |t|
  puts "user save"
  t.save!
end

cars.each do |t|
  puts "cars save"
  t.save!
end

trips.each do |t|
  puts "trips save"
  t.save!
end

requests.each do |t|
  puts "request save"
  t.save!
end


#Erstellen von Passengers
#x=0
#passengers=[]
#puts "Passengers Erstellen"
#until x==anzpassenger
  #x=x+1
  #puts "Passengers "+x.to_s
  #trip = Trip.all[rand(anztrips)]
  #begin
    #user = User.all[rand(anzusers)]
  #end while((user == trip.user) ^ trip.users.include?(user))
  #confirmed = rand(2)
  #con=false
  #if confirmed==0
    #con=true
  #end
  #ps = Passenger.new :user_id => user, :trip_id => trip, :confirmed => con
  #passengers << ps
#end

#Erstellen von  Ratings
#x=0.rb:30:in `not_his_own_driver'
#ratings=[]
#puts "Ratings Erstellen"
#until x==anzratings
  #x=x+1
  #puts "Ratings "+x.to_s
  #trip_id = rand(anztrips+1)
  #t = Trip.all[trip_id]
  #Autor und Empfänger bestimmen
  #random = t.users.count
  #author = User.all[rand(random)]
  #begin
    #receiver = User.all[rand(random)]
  #end while(author.id = receiver.id)
  #ra = Rating.new :comment => "Auto im schlechten Zustand!", :mark => rand(6), :trip_id => trip_id, :receiver_id => receiver.id, :author_id => author.id
  #ratings << ra
#end


#passengers.each do |t|
  #puts "passenger save"
  #t.save!
#end

#ratings.each do |t|
  #r.save!
#end
