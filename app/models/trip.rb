#
# Modelliert alle Fahrten die ein User als Fahrer oder Mitfahrer begeht. 
# 
# ===Das Model hat die Datenfelder:
#
# * trip_id       :integers -- <i>Von Rails erstellt</i> ID des Trips
# * user_id       :integers -- ID des <b>fahrenden</b> Users
# * car_id        :integers -- ID des <b>benutzten</b> Autos des fahrenden Users
# * starts_at_N   :float    -- <i>Bei Erstellung automatisch eingefügt</i> Startkoordinate Nördl. Breite
# * starts_at_E   :float    -- <i>Bei Erstellung automatisch eingefügt</i> Startkoordinate Östl. Breite
# * ends_at_N     :float    -- <i>Bei Erstellung automatisch eingefügt</i> Endkoordinate Nördl. Breite
# * ends_at_E     :float    -- <i>Bei Erstellung automatisch eingefügt</i> Endkoordinate Östl. Breite
# * address_start :string   -- Durch den User eingegebene Startadresse 
# * address_end   :string   -- Durch den User eingegebene Endadresse
# * start_time    :datetime -- Voraussichtliche Startzeit des Trip
# * comment       :text     -- Kommentar zum Text
# * created_at    :datetime -- <i>Von Rails erstellt</i> Erstellungsdatum des Objekts
# * updated_at    :datetime -- <i>Von Rails erstellt</i> letztes Änderungsdatum des Objekts
# * baggage       :boolean  -- Datenfeld ob Gepäck erlaubt ist
# * free_seats    :integer  -- Noch freie Sitze des Autos auf der Fahrt
# * distance      :integer  -- <i>Bei Erstellung automatisch eingefügt</i> Länge der zu fahrenden Strecke
# * duration      :integer  -- <i>Bei Erstellung automatisch eingefügt</i> Dauer der zu fahrenden Strecke
#
# ===Das Model Trips arbeitet mit folgenden Validations:
#
# <b>validates_presence_of</b> (" Datenfelder dürfen nicht Null sein, bzw. müssen beim Anlegen eines neuen Trips ausgefüllt werden")
#
# * :address_start       
# * :address_end
# * :start_time  
# * :free_seats
# * :starts_at_N
# * :starts_at_E
# * :ends_at_N
# * :ends_at_E
# * :duration
# * :distance
#
# <b>validates_inclusion_of</b> ("Datenfelder müssen eine bestimmte Länge aufweisen")
#  
# * :free_seats -- " > 1" ("Es macht keinen Sinn eine Fahrt zu erstellen die keine freien Plätze zu Verfügung hat")
# 
# <b>validates</b> ("selbstgeschrieben Validation-Methoden, Beschreibungen bei den jeweiligen Methoden")
# 
# * :start_time_in_past
# * :start_address_same_as_end_address
# * :baggage_not_nil
#
# <b>Validation der Beziehungen<i>":dependent => :destroy"</i></b>
# 
# * has_many :ratings -- Wenn Trip gelöscht, dann auch alle Ratings löschen, die der Trip erhalten hat
# * has_many :passengers -- Wenn Trip gelöscht, dann auch alle zugehörigen Passagiere löschen
# 
# ===Beziehungen
#
# * belongs_to :user
# * belongs_to :car
# * has_many :users ("as passenger_trip")


class Trip < ActiveRecord::Base
  include ActiveModel::Validations
  require 'bing/route'
  require 'bing/location'
  ############################== Modellierung der Beziehungen #####################################

  #Der aktive Fahrer, zu dem jeweils ein Trip gehört
  belongs_to :user

  #Das benutzte Auto des Fahrenden
  belongs_to :car
  
  #Die potentiellen Mitfahrer des Fahrers, ermittelt über die Join-Entität Passengers. Hierbei
  #werden direkt Userobjekte zurückgeliefert, da diese über den Join mit den Fahrten in Verbindung
  #gebracht werden.
  has_many :users, :class_name => "User", :as => "passenger_trip", :through => :passengers, 
    :source => :user

  #Fahrer und Mitfahrer bewerten sich untereinander zu einem bestimmten Trip
  has_many :ratings, :dependent => :destroy

  #Direkte Beziehung zur Join-Entität Passengers
  has_many :passengers, :dependent => :destroy
  

 # before_save :set_address_info, :set_route

  def set_address_info
    
    puts "hallo da bin ich"
    start_a =  Gmaps4rails.geocode(self.starts_at_N.to_s  + "N " + 
               self.starts_at_E.to_s + "E", "de")[0][:full_data]
    

    start_a["address_components"].each do |i|
      if i["types"].include?("postal_code")
        start_zipcode = i["long_name"]
      end
      if i["types"].include?("locality")
        start_city = i["long_name"]
      end
      if i["types"].include?("route")
         start_street = i["long_name"]
      end
      if i["types"].include?("street_number")
        start_street = start_street + " "+ i["long_name"]
      end
     end
    

    end_a =  Gmaps4rails.geocode(self.ends_at_N.to_s  + "N " + 
               self.ends_at_E.to_s + "E", "de")[0][:full_data]
    
    end_a["address_components"].each do |i|
      if i["types"].include?("postal_code")
        end_zipcode = i["long_name"]
      end
      if i["types"].include?("locality")
        end_city = i["long_name"]
      end
      if i["types"].include?("route")
         street = i["long_name"]
      end
      if i["types"].include?("street_number")
        hausNr = i["long_name"]
      end
     end
    end_street = (street.to_s + " " +  hausNr.to_s)

  end 


  #Validation, eine Fahrt muss ein Datum, Startort, Zielort, freie Sitzplätze haben

  validate :start_time_in_past, :start_address_same_as_end_address, :baggage_not_nil

  validates_presence_of :start_city, :end_city, :start_time, :free_seats, :starts_at_N, :starts_at_E, :ends_at_N, :ends_at_E, :duration, :distance
  
  #Freie Sitzplätze dürfen nicht negativ sein
  validates_inclusion_of :free_seats, :in => 1..200

  # Methode prüft, ob ein erstellter Trip in der Vergangenheit liegt
  #
  # @throws Error, wenn Startzeit < aktuelle Zeit
  def start_time_in_past
    if start_time < Time.now
      errors.add(:fields, 'Startzeit liegt in der Vergangenheit')
    end
  end
  

  # Methode prüft, ob Start- gleich Zieladdresse ist 
  #
  # @throws Error, wenn Startpunkt = Zielpunkt
  def start_address_same_as_end_address
    if (starts_at_N == ends_at_N and starts_at_E == ends_at_E)
      errors.add(:field, 'Startadresse = Endadresse, Fahrt lohnt sich nicht')
    end    
  end


  # Baggage darf nicht Null sein
  #
  # @throws Error, wenn Baggage nicht gesetzt ist
  def baggage_not_nil
    if(self.baggage == nil)
      errors.add(:field, 'Baggage ist Null')
    end
  end


 ########################## Methoden ########################



  #Methoden:
  #toString Methode für Trips
  def to_s
    id 
  end
  

  # Methode die alle passenden Requests sucht, die auf einen Trip zutreffen.
  # Dazu werden die jeweiligen Startzeiten ("Trip und Request")verglichen und die Entfernung der Start- und Zielorte in einem bestimmten Radius übereinstimmt.
  # 
  # @return        -- Array mit passenden Request-Objekten
  def get_available_requests
    start_f =start_time.to_f
    erg = []
    
    # Hole alle Requests
    Request.all.each do |t|
      # prüfe pro Request ob die Startzeiten von Trip und Request übereinstimmen
      if (start_f.between?(t.start_time.to_f, t.end_time.to_f) and
        # prüfe ob die Entfernung des Startortes in einem bestimmten Radius übereinstimmt
         ((Geocoder::Calculations.distance_between [t.starts_at_N, t.starts_at_E], 
         [starts_at_N, starts_at_E], :units => :km) <= t.start_radius) and
        # prüfe ob die Entfernung des Endortes in einem bestimmten Radius übereinstimmt
         ((Geocoder::Calculations.distance_between [t.ends_at_N, t.ends_at_E], 
         [ends_at_N, ends_at_E], :units => :km)  <= t.end_radius)) and
        # prüfe ob der User der den Request gestellt hat ignoriert wird
         !self.user.ignorings.include?(t.user) then
        # Ergebnisarray mit Requests füllen auf denen diese Eigenschaften zutreffen
        erg << t
      end
    end
    return erg
  end

  # Methode zur Optimierung der Ergebnismenge aus gestellten Request.
  def get_sorted_requests
    requests = get_available_requests
    erg = []

    requests.each do |t|
     # address_start = t.start_city
     # address_end = t.end_city
     # start_con = Gmaps4rails.destination({"from" => self.start_city, "to" => address_start},{},"pretty")
     # end_con =  Gmaps4rails.destination({"from" =>end_city, "to" => address_end},{},"pretty") 
     # start_distance = start_con[0]["distance"]["value"]
     # start_duration = start_con[0]["duration"]["value"]
     # end_distance = end_con[0]["distance"]["value"]
     # end_duration = end_con[0]["duration"]["value"]
      bing_information = Bing::Route.find(:waypoints => [self.starts_at_N.to_s+"N "+self.starts_at_E.to_s+"E",
                                                         t.starts_at_N.to_s + "N "+ t.starts_at_E.to_s+"E",
                                                         t.ends_at_N.to_s + "N "+ t.ends_at_E.to_s+"E",
                                                         self.ends_at_N.to_s+"N "+self.ends_at_E.to_s+"E"])[0]
 
      distance= bing_information.total_distance
      duration = bing_information.total_duration
      
      t_rating = t.user.get_avg_rating.to_f / 6
      t_ignors = t.user.get_relative_ignorations
      detour = (distance - self.distance) / self.distance
      detime = (duration - self.duration) / self.duration

      erg << [t, Math.sqrt(t_rating*t_rating + t_ignors*t_ignors + detour*detour + detime*detime)]
    end

    erg.sort{|a,b| a[1] <=> b[1]}
    
  end


  # Liefert die Anzahl freier Sitzplätze, die noch nicht vergeben sind
  #
  # @return Anzahl freier Sitzplätze
  def get_free_seats
    return free_seats - get_occupied_seats
  end
  
  # Liefert die Anzahl belegter Sitzpläte des benutzten Autos
  #
  # @return s.o.
  def get_occupied_seats
    count = 0
    self.passengers.all.each do |p|
      if p.confirmed then
        count += 1
      end
    end
    return count
  end


  # Liefert alle User dieses Trips, die schon committed wurden
  #
  # @return erg [] -- mit Passengers, die confirmed sind
  def get_committed_passengers
    erg = []
    self.passengers.all.each do |p|
      if p.confirmed then
        erg << p.user
      end
    end
    return erg
  end

  # liefert alle user dieses Trips, die (noch) nicht committed wurden
  #
  # @return erg [] -- mit Passengers, die nicht confirmed sind
  def get_uncommitted_passengers
    erg = []
    self.passengers.all.each do |p|
      if !p.confirmed then
        erg << p.user
      end
    end
    return erg
  end

  # Berechnet die Strecke in Metern und die Zeit in Sekunden, die für diese Strecke benötigt werden und schreibt die Informationen in die passenden Datenfelder der Tabelle
  def set_route
    route = Bing::Route.find(:waypoints => [self.starts_at_N.to_s+"N " + self.starts_at_E.to_s + "E",
                                            self.ends_at_N.to_s+"N " + self.ends_at_E.to_s+"E"])[0]
    self.distance = route.total_distance
    self.duration = route.total_duration
  end
  
  # Berechnet die Zeit die benötigt wird und gibt diese formatiert aus
  #
  # @return Zeit ( x Stunden y Minuten)
  def get_route_duration
    return duration.div(3600).to_s+" Stunden "+(duration % 60).to_s+ " Minuten" 
  end
 
  # Berechnet die Distanz die benötigt wird und gibt diese formatiert aus
  #
  # @return Distanz ( x Km)
  def get_route_distance
    return (distance / 1000).round(3).to_s + "km"
  end

  # Gibt aus ob ein übergeben User für den Trip akzeptiert wurde
  # 
  # @param compared_user -- User der vom controller übergeben wird
  #
  # @return (true, falls angenommen; false sonst)
  def user_uncommitted (compared_user)
    get_uncommitted_passengers.include?(compared_user)
  end
  
  # Gibt aus ob ein übergebender User für deine Trip noch nicht akzeptiert wurde
  # 
  # @param compared_user -- User der vom controller übergeben wird
  #
  # @return (true, falls (noch) nicht angenommen; false sonst)
  def user_committed (compared_user)
    get_committed_passengers.include?(compared_user)
  end
  
  # Methode um als Fahrer einen User, der sich um Mitfahrt beworben hat, anzunehmen. Dabei wird das Datenfeld confirmed in der Tabelle Passengers auf true gesetzt
  #
  # @param compared_user -- User der vom controller übergeben wird
  #
  # @return true, wenn Update erfolgreich; false sonst
  def accept (compared_user)
    if self.passengers.where("user_id = ?", compared_user.id).first.confirmed?
        false
      else
        begin
          self.passengers.where("user_id = ?", compared_user.id).first.update_attribute(:confirmed, true)
          true
        rescue Error
          false
        end
      end
    end
  
  # Methode um als Fahrer einen User, der sich um Mitfahrt beworben hat, abzulehnen. Dieser wird hierbei direkt aus der Mitfahrertabelle (Passengers) gelöscht.
  #
  # @param compared_user -- User der vom controller übergeben wird
  #
  # @return true, wenn Löschvorgang erfolgreich; false sonst
  def declined (compared_user)
    begin
      self.passengers.where("user_id = ?", compared_user.id).first.destroy
    rescue Error
      false
    end
    true
  end
  
  # Methode, die angibt, ob ein Trip schon beendet ist
  #
  # @return true, wenn der Trip in der Vergangenheit liegt; false sonst
  def finished
    if self.start_time < Time.now 
      true
    else 
      false
    end
  end
  
  # Liefert alle Mitfahrer des Trips
  #
  # @return User [] erg
  def get_passengers
    erg = []
    self.passengers.all.each do |p|
      erg << p.user
    end
    erg
  end

  # Füllt einen Hash mit Adressinformationen der Startadresse.
  # "get_start_address_info[:street]" um an die Straße zu kommen
  # "get_start_address_info[:city]" um an den Stadtnamen zu kommen
  # "get_start_address_info[:plz]" um an die PLZ zu kommen
  #
  # @return Hash mit Feldern: Straße, Stadt, PLZ
  # 
  def get_start_address_info 
    erg = {}
    erg[:city] = start_city
    erg[:plz] = start_zipcode
    erg[:street] = start_street
    #street = ""
    #hausNr = ""
    # fülle das infos Array mit allen Informationen, die von gmaps4rails geliefert werden
    #infos = Gmaps4rails.geocode(self.starts_at_N.to_s  + "N " + 
    #        self.starts_at_E.to_s + "E", "de")[0][:full_data]
    
    #infos["address_components"].each do |i|
    #  if i["types"].include?("postal_code")
    #    erg[:plz] = i["long_name"]
    #  end
    #  if i["types"].include?("locality")
    #    erg[:city] = i["long_name"]
    #  end
    #  if i["types"].include?("route")
    #    street = i["long_name"]
    #  end
    #  if i["types"].include?("street_number")
    #    hausNr = i["long_name"]
    # end
    #end
    #
    #erg[:street] = street + " " + hausNr
    return erg
  end
  
  # Füllt einen Hash mit Adressinformationen der Endadresse.
  # "get_end_address_info[:street]" um an die Straße zu kommen
  # "get_end_address_info[:city]" um an den Stadtnamen zu kommen
  # "get_end_address_info[:plz]" um an die PLZ zu kommen
  #
  # @return Hash mit Feldern: Straße, Stadt, PLZ
  def get_end_address_info
    
    erg = {}
    erg[:city] = end_city
    erg[:plz] = end_zipcode
    erg[:street] = end_street
    # street = ""
    # hausNr = ""
    # infos = Gmaps4rails.geocode(self.ends_at_N.to_s  + "N " + 
    #                            self.ends_at_E.to_s + "E", "de")[0][:full_data]
    # infos["address_components"].each do |i|
    #   if i["types"].include?("postal_code")
    #    erg[:plz] = i["long_name"]
    #  end
    #  if i["types"].include?("locality")
    #    erg[:city] = i["long_name"]
    #  end
    #  if i["types"].include?("route")
    #    street = i["long_name"]
    #  end
    #  if i["types"].include?("street_number")
    #    hausNr = i["long_name"]
    #  end
    # end
    # erg[:street] = street + " " + hausNr
    
    return erg
  end
  
  def get_start_city
    get_start_address_info[:city]
  end
  
  def get_end_city
    get_end_address_info[:city]
  end
end
