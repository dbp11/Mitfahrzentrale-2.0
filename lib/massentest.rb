# encoding: utf-8
# Massentest für die Datenbank, d.h. hier werden die dafür benötigten Daten erstellt
require "plzliste"

#Anzahl der zu erstellenden Entities
anzusers = 100
anztrips = 400
anzcars = 120
anzrequests = 400
anzratings = 150
anzpassenger = 200

#Erstellen von  Users
x=0
users=[]
until x==anzusers
  x=x+1
  plz=@plz_array[rand(24119)]
  u=User.new :email => "Test"+x.to_s+"@uos.com", :password => "dkruempe",:password_confirmation => "dkruempe", :name => "Dominik Krümpelmann", :user_type => true, :sex => true, :address => "Großer Esch 20", :addressN => "effse", :addressE => "fsefsf", :zipcode => plz, :phone => "054571598"+x.to_s, :instantmessenger => "icq: 5465465"+x.to_s, :city => "Hopsten", :email_notifications => true, :visible_phone => true, :visible_email => true, :visible_address => true, :visible_age => true, :visible_im => true, :visible_cars => true, :birthday => Date.new(1989,12,28), :visible_zip => true, :user_type => false, :visible_city => true, :business => false, :last_delivery => Time.now, :last_ratings => Time.now, :role => "member"
  users << u
end

#Erstellen von  Cars
cars=[]
until x==anzcars
    c= Car.new :user_id => (rand(anzusers+1)), :seats => 5, :licence => "10234", :price_km => 5.5, :smoker => true, :description => "Kein Kofferraum", :car_type => "BMW"
  cars << c
end

#Erstellen von  Trips

trips=[]
until x==anztrips
  user_id = (rand(anzusers+1))
  plz_start = @plz_array[rand(24119)]
  begin
    plz_ende = @plz_array[rand(24119)]
  end while plz_start=plz_ende
  #start_koordinaten
  start=Geocoder.coordinates(plz_start)
  start[0]=starts_N
  start[1]=starts_E

  #end_koordinaten 
  ende=Geocoder.coordinates(plz_ende)
  ende[0]=ends_N
  ende[1]=ends_E
  t=Trip.new :user_id => user_id, :car_id => User.all[user_id], :starts_at_N => start_N, :starts_at_E => starts_E, :ends_at_E => ends_E, :ends_at_N => ends_N, :start_zipcode => start, :address_zipcode => ende, :start_time => Time.now+1.day, :comment => "Biete eine Fahrt an!", :baggage => true, :free_seats => 5
  t.set_routes
  trips << t
end

#Erstellen von  Requests

requests=[]
until x==anzrequests
  user_id = rand(anzUsers)
  plz_start = @plz_array[rand(24119)]
  begin
    plz_ende = @plz_array[rand(24119)]
  end while plz_start=plz_ende
  #start_koordinaten
  start=Geocoder.coordinates(plz_start)
  start[0]=starts_N
  start[1]=starts_E

  #end_koordinaten 
  ende=Geocoder.coordinates(plz_ende)
  ende[0]=ends_N
  ende[1]=ends_E

  r = Request.new :starts_at_N => starts_N, :starts_at_E => starts_E, :ends_at_N => ends_N, :ends_at_E => ends_E, :start_zipcode => start, :end_zipcode => ende, :start_time => Time.now+1.day, :end_time => Time.now+365.day, :baggage => true, :comment => "Hilfe", :user_id => user_id, :start_radius => rand(51), :end_radius => rand(51)
  r.set_routes
  requests << r
end

#Erstellen von  Ratings

ratings=[]
until x==anzratings
  trip_id = rand(anztrips+1)
  t = Trip.all[trip_id]
  #Autor und Empfänger bestimmen
  random = t.users.count
  author = User.all[rand(random)]
  begin
    receiver = User.all[rand(random)]
  end while(author.id = receiver.id)
  ra = Rating.new :comment => "Auto im schlechten Zustand!", :mark => rand(6), :trip_id => trip_id, :receiver_id => receiver.id, :author_id => author.id
  rarings << ra
end

#Erstellen von 15000 Passengers
passengers=[]
until x==anzpassenger
  trip = Trip.all[rand(anztrips+1)]
  user = User.all[rand(anzusers+1)]
  confirmed = rand(2)
  con=false
  if confirmed==0
    con=true
  end
  ps = Passenger.new :user_id => user, :trip_id => trip, :confirmed => con
  passengers << ps
end

#Erstellen der Daten
users.each  do |t|
  t.save!
end

cars.each do |t|
  t.save!
end

trips.each do |t|
  t.set_address_info
  t.save!
end

requests.each do |t|
  t.set_address_info
  t.save!
end

passengers.each do |t|
  t.save!
end

ratings.each do |t|
  r.save!
end
