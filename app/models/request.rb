class Request < ActiveRecord::Base

############################# == Beziehungen   ############################
 
  #Beziehunge
  belongs_to :user
  
############################# == Validations   ############################
  
  
  #Validation
  validates_presence_of :duration, :distance, :starts_at_N, :starts_at_E, :ends_at_N, :ends_at_E, :start_time, :end_time, :start_radius, :end_radius, :user_id, :start_city, :end_city
  
  validate :start_time_in_past, :end_time_bigger_start_time, :baggage_not_nil, :start_address_same_as_end_address

  def start_time_in_past
    if self.start_time < Time.now
      errors.add(:fields, 'Die Startzeit liegt in der Vergangenheit')
    end
  end

  def end_time_bigger_start_time
    if self.end_time <= self.start_time
      errors.add(:fields, 'Die Endzeit ist kleiner als die Startzeit')
    end
  end

  #Baggage darf nicht Null sein
  def baggage_not_nil
    if(self.baggage == nil)
      errors.add(:field, 'baggage ist Null')
    end
  end

  def start_address_same_as_end_address
    if (starts_at_N == ends_at_N and starts_at_E == ends_at_E)
      errors.add(:field, 'Startadresse = Endadresse, Fahrt lohnt sich nicht')
    end    
  end


########################   Methoden für Controller   #######################
  

  #Methode die alle zum Radius des suchenden Users die passenden Trips sucht
  #@return Array von Trips
  def get_available_trips
    start_f =start_time.to_f
    end_f = end_time.to_f
    erg = []

    Trip.all.each do |t|
      if t.get_free_seats >= 1 and t.start_time.to_f.between?(start_f, end_f) and 
          ((Geocoder::Calculations.distance_between [t.starts_at_N, t.starts_at_E], 
           [starts_at_N, starts_at_E], :units => :km) <= self.start_radius) and
          ((Geocoder::Calculations.distance_between [t.ends_at_N, t.ends_at_E], 
           [ends_at_N, ends_at_E], :units => :km)  <= self.end_radius) and 
           (!self.baggage and !t.baggage or t.baggage) and
           !self.user.ignorings.include?(t.user)
           then erg << t
      end
    end
    return erg
  end

  #Berechnet Trips, die sich nur geringfügig von dieser Request unterscheiden, und gibt ein Array aus
  #Wertepaaren zurück. Der erste Wert ist der Trip, der zweite gibt die Länge des Umweges an, den der
  #Fahrer dieses Trips in Kauf nehmen müsste. Das Array ist absteigend nach Umwegen sortiert.
  def get_sorted_trips
    trips = get_available_trips
    erg = []
    trips.each do |t|
      #address_start = t.city
      #address_end = t.city
      #start_con = Gmaps4rails.destination({"from" => address_start, "to" => self.start_city},{},"pretty")
      #end_con =  Gmaps4rails.destination({"from" => address_end, "to" =>self.end_city},{},"pretty")
       start_distance = (Geocoder::Calculations.distance_between [t.starts_at_N, t.starts_at_E], 
           [self.starts_at_N, self.starts_at_E], :units => :km)
       end_distance = (Geocoder::Calculations.distance_between [t.ends_at_N, t.ends_at_E], 
           [self.ends_at_N, self.ends_at_E], :units => :km)

     # start_distance = start_con[0]["distance"]["value"]
     # start_duration = start_con[0]["duration"]["value"]
       start_duration = start_distance / 1000 / 80
     # end_distance = end_con[0]["distance"]["value"]
     # end_duration = end_con[0]["duration"]["value"]
       end_duration = end_distance / 1000 / 80

      t_rating = t.user.get_avg_rating.to_f / 6
      t_ignors = t.user.get_relative_ignorations
      detour = (start_distance + end_distance + self.distance - t.distance) / t.distance
      detime = (start_duration + end_duration + self.duration - t.duration) / t.duration

      erg << [t, Math.sqrt(t_rating*t_rating + t_ignors*t_ignors + detour*detour + detime*detime)]
    end

    erg.sort{|a,b| a[1] <=> b[1]}
    
  end


  def set_route
    route = Gmaps4rails.destination({"from" =>self.starts_at_N.to_s+"N "+self.starts_at_E.to_s+"E", "to" =>self.ends_at_N.to_s+"N "+self.ends_at_E.to_s+"E"},{},"pretty")

    self.distance = route[0]["distance"]["value"]
    self.duration = route[0]["duration"]["value"]
  end


  # Berechnet die Zeit die benötigt wird und gibt diese formatiert aus
  #
  # @return Zeit ( x Stunden y Minuten)
  def get_route_duration
    hours = duration.div(3600)
    minutes = (duration % 60)
    ergstring = ""
    if hours < 10
      ergstring += "0"
    end
    ergstring += hours.to_s + ":"
    if minutes < 10
      ergstring += "0"
    end
    ergstring += minutes.to_s + " h"

    return ergstring 
  end
 
  # Berechnet die Distanz die benötigt wird und gibt diese formatiert aus
  #
  # @return Distanz ( x Km)
  def get_route_distance
    return (distance / 1000).round(3).to_s + "Km"
  end

end

