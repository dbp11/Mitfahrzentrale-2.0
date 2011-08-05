class GeoHelper
  def self.api
    @api ||= :gmaps
  end

  def self.api=(new_api)
    @api = new_api
  end
  
  #Berechnet die Route 
  def self.destination(start_end, options = {}, output = "pretty") 
    if api == :gmaps
      Gmaps4Rails.destination(start_end, options, output)      
    else if api == :geocoder
      Geocoder::Calculations.distance_between(start_end['from'],start_end['to'],{:units => :km})
    end
  end
  

  #Liefert für Koordinaten die Standorte
  def self.geocode
  end
end
