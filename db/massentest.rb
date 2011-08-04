# encoding: utf-8
# Massentest für die Datenbank, d.h. hier werden die dafür benötigten Daten erstellt

#Erstellen von 10000 Users
x=0
until x==10000
User.new :email => "Test"+x.to_s+"@uos.com", :password => "dkruempe",:password_confirmation => "dkruempe", :name => "Dominik Krümpelmann", :user_type => true, :sex => true, :address => "Großer Esch 20", :addressN => 52.57975, :addressE => 8.13409, :zipcode => 48496, :phone => "054571598"+x.to_s, :instantmessenger => "icq: 5465465"+x.to_s, :city => "Hopsten", :email_notifications => true, :visible_phone => true, :visible_email => true, :visible_address => true, :visible_age => true, :visible_im => true, :visible_cars => true, :birthday => Date.new(1989,12,28), :visible_zip => true, :user_type => false, :visible_city => true, :business => false
end

#Erstellen von Trips
#Erstellen von Requests
#Erstellen von Ratings
#Erstellen von Messages
#Erstellen von Cars
#Erstellen von Passengers
#Erstellen von Ignorings-Beziehungen
