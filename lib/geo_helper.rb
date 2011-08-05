class GeoHelper
  def self.api
    @api ||= :gmaps
  end

  def self.api=(new_api)
    @api = new_api
  end
  
  #Berechnet die Route 
  def self.destination(start_end, options = {}, output = "pretty") 
    puts "GeoHelper#destination"
    if api == :gmaps
      Gmaps4Rails.destination(start_end, options, output)      
    elsif api == :geocoder
      puts start_end[:from]
      puts start_end[:to]
      Geocoder::Calculations.distance_between(start_end[:from],start_end[:to],{:units => :km})
    end
  end
  

  #Liefert für Koordinaten die Standorte
  def self.geocode(cord_at_N, cord_at_E)
    if api == :gmaps
      Gmaps4rails.geocode(cord_at_N.to_s+ "N "+ cord_at_E+"E","de")[0][:full_data]
    elsif api == :geocoder
      Geocoder.address([cord_at_N,cord_at_E])
    end
  end
end
