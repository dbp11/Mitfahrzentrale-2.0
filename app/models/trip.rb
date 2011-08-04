# =Klasse Trip
#
# Modelliert alle Fahrten die ein User als Fahrer oder Mitfahrer begeht. Das Modell hat die 
# Datenfelder
#
# *trip_id :integers --<i>Von Rails erstellt</i> ID des Trips
# *user_id :integers -- ID des Fahrenden Users
# *car_id :integers -- ID des benutzten Autos des fahrenden Users
# *starts_at_N :float -- <i>Bei Erstellung automatisch eingefügt</i> Startkoordinate Nördl. Breite
# *starts_at_E :float -- <i>Bei Erstellung automatisch eingefügt</i> Startkoordinate Östl. Breite
# *ends_at_N :float -- <i>Bei Erstellung automatisch eingefügt</i> Endkoordinate Nördl. Breite
# *ends_at_E :float -- <i>Bei Erstellung automatisch eingefügt</i> Endkoordinate Östl. Breite
# *address_start :string -- Durch den User eingegebene Startadresse 
# *address_end :string -- Durch den User eingegebene Endadresse
# *start_time :datetime -- Voraussichtliche Startzeit des Trip
# *comment :text -- Kommentar zum Text
# *created_at :datetime -- <i>Von Rails erstellt</i> Erstellungsdatum des Objekts
# *updated_at :datetime <i>Von Rails erstellt</i> letztes Änderungsdatum des Objekts
# *baggage :boolean -- Datenfeld ob Gepäck erlaubt ist
# *free_seats :integer -- Noch freie Sitze des Autos auf der Fahrt
# *distance :integer -- <i>Bei Erstellung automatisch eingefügt</i> Länge der zu fahrenden Strecke
# *duration :integer -- <i>Bei Erstellung automatisch eingefügt</i> Dauer der zu fahrenden Strecke


class Trip < ActiveRecord::Base
  include ActiveModel::Validations

  ############################== Modellierung der Beziehungen #####################################

  #Der aktive Fahrer, zu dem jeweils ein Trip gehört
  belongs_to :user

  #Das benutzte Auto des Fahrenden
  belongs_to :car
  
  #Die potentiellen Mitfahrer des Fahrers, ermittelt über die Join-Entität Passengers. Hierbei
  #werden direkt Userobjekte zurückgeliefert, da diese über den Join mit den Fahrten in Verbindung
  #gebracht werden.
  has_many :users, :class_name => "User", :as => "passenger_trip", :through => :passengers, 
    :source => :user, :dependent => :destroy

  #Fahrer und Mitfahrer bewerten sich untereinander zu einem bestimmten Trip
  has_many :ratings, :dependent => :destroy

  #Direkte Beziehung zur Join-Entität Passengers
  has_many :passengers, :dependent => :destroy
  

  #Validation, eine Fahrt muss ein Datum, Startort, Zielort, freie Sitzplätze haben

  validate :start_time_in_past, :start_address_same_as_end_address, :baggage_not_nil

  validates_presence_of :address_start, :address_end, :start_time, :free_seats, :starts_at_N, :starts_at_E, :ends_at_N, :ends_at_E, :duration, :distance
  
  #Freie Sitzplätze dürfen nicht negativ sein
  validates_length_of :free_seats, :minimum => 1

  # Methode prüft ob ein erstellter Trip in der Vergangenheit liegt
  # @throws Error, wenn Startzeit in der Vergangenheit
  def start_time_in_past
    if start_time < Time.now
      errors.add(:fields, 'Startzeit liegt in der Vergangenheit')
    end
  end
  
  # Start- und Endaddresse dürfen nicht übereinstimmen
  # @throws Error, wenn Startpunkt = Zielpunkt
  def start_address_same_as_end_address
    if (starts_at_N == ends_at_N and starts_at_E == ends_at_E)
      errors.add(:field, 'Startadresse = Endadresse, Fahrt lohnt sich nicht')
    end    
  end

  # Baggage darf nicht Null sein
  # @throws Error, wenn Baggage nicht ge<i>Bei Erstellung automatisch eingefügt</i> Startkoordinate Nördl. Breitesetzt ist
  def baggage_not_nil
    if(self.baggage == nil)
      errors.add(:field, 'Baggage ist Null')
    end
  end

  #Methoden:
  #toString Methode für Trips
  def to_s
    id 
  end
  

  #Methode die alle passenden Requests sucht
  #@return Array von Requests
  def get_available_requests
    start_f =start_time.to_f
    erg = []

    Request.all.each do |t|
      if (start_f.between?(t.start_time.to_f, t.end_time.to_f) and 
          ((Geocoder::Calculations.distance_between [t.starts_at_N, t.starts_at_E], 
           [starts_at_N, starts_at_E], :units => :km) <= t.start_radius) and
          ((Geocoder::Calculations.distance_between [t.ends_at_N, t.ends_at_E], 
           [ends_at_N, ends_at_E], :units => :km)  <= t.end_radius)) then 
        erg << t
      end
    end
    return erg
  end

  #Berechnet Trips, die sich nur geringfügig von dieser Request unterscheiden, und gibt ein Array aus
  #Wertepaaren zurück. Der erste Wert ist der Trip, der zweite gibt die Länge des Umweges an, den der
  #Fahrer dieses Trips in Kauf nehmen müsste. Das Array ist absteigend nach Umwegen sortiert.
  def get_sorted_requests
    requests = get_available_requests
    erg = []

    requests.each do |t|
      start_con = Gmaps4rails.destination({"from" => self.address_start, "to" => t.address_start},{},"pretty")
      end_con =  Gmaps4rails.destination({"from" => self.address_end, "to" => t.address_end},{},"pretty")
      
      start_distance = start_con[0]["distance"]["value"]
      start_duration = start_con[0]["duration"]["value"]

      end_distance = end_con[0]["distance"]["value"]
      end_duration = end_con[0]["duration"]["value"]

      t_rating = t.user.get_avg_rating.to_f / 6
      t_ignors = t.user.get_relative_ignorations
      detour = (t.distance + end_distance + self.distance - start_distance) / start_distance
      detime = (t.duration + end_duration + self.duration - start_duration) / start_duration

      erg << [t, Math.sqrt(t_rating*t_rating + t_ignors*t_ignors + detour*detour + detime*detime)]
    end

    erg.sort{|a,b| a[1] <=> b[1]}
    
  end


  #liefert die Anzahl freier Sitzplätze, die noch nicht vergeben sind
  def get_free_seats
    return free_seats - get_occupied_seats
  end
  
  # liefert die Anzahl belegter Sitzpläte
  def get_occupied_seats
    count = 0
    self.passengers.all.each do |p|
      if p.confirmed then
        count += 1
      end
    end
    return count
  end


  #liefert alle user dieses Trips, die schon committed wurden
  def get_committed_passengers
    erg = []
    self.passengers.all.each do |p|
      if p.confirmed then
        erg << p.user
      end
    end
    return erg
  end

  #liefert alle user dieses Trips, die (noch) nicht committed wurdeni
  def get_uncommitted_passengers
    erg = []
    self.passengers.all.each do |p|
      if !p.confirmed then
        erg << p.user
      end
    end
    return erg
  end

  # Berechnet die komplette Route mit allen Zwischenziele
  def set_route
    route = Gmaps4rails.destination({"from" =>address_start, "to" =>address_end},{},"pretty")

    self.distance = route[0]["distance"]["value"]
    self.duration = route[0]["duration"]["value"]
  end
  
  # Berechnet die Entfernung in Metern
  def get_route_duration
    return duration.div(3600)+"Stunden"+(duration % 60)+ "Minuten" 
  end
 
  # Berechnet die benötigte Zeit in Sekunden
  def get_route_distance
    return (distance / 1000).round(3) + "Km"
  end



  def user_uncommitted (compared_user)
    get_uncommitted_passengers.include?(compared_user)
  end

  def user_committed (compared_user)
    get_committed_passengers.include?(compared_user)
  end

  def accept (compared_user)
    self.passengers.where("user_id = ?", compared_user.id).first.confirmed = true
  end

  def declined (compared_user)
    self.passengers.where("user_id = ?", compared_user.id).first.destroy
  end
  
  def finished
    if self.start_time < Time.now 
      true
    else 
      false
    end
  end
  
  def get_passengers
    erg = []
    self.passengers.all.each do |p|
      erg << p.user
    end
    erg
  end
end
