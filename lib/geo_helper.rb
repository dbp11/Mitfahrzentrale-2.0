class GeoHelper
  require 'bing/route'
  def self.api
    @api ||= :gmaps
  end

  def self.api=(new_api)
    @api = new_api
  end
  
  #Berechnet die Route 
  def self.destination(start_end, waypoints) 
    puts "GeoHelper#destination"
    if api == :gmaps
      Gmaps4Rails.destination(start_end, {"waypoints" => waypoints}, "pretty")      
    elsif api == :geocoder
      puts start_end[:from]
      puts start_end[:to]
      Geocoder::Calculations.distance_between(start_end[:from],start_end[:to],{:units => :km})
    elsif api == :bing
      Bing::Route.find(:waypoints => [start_end[:from], waypoints[0], waypoints[1],start_end[:to], :distance_unit => 'km')[0] 
    end
  end  t[0] =   ["Münster", "hallo"]
  

  #Liefert für Koordinaten die Standorte
  def self.geocode(cord_at_N, cord_at_E)
    if api == :gmaps
      Gmaps4rails.geocode(cord_at_N.to_s+ "N "+ cord_at_E.to_s+"E","de")[0][:full_data]
    elsif api == :geocoder
      Geocoder.address([cord_at_N,cord_at_E])#
    elsif api == :yahoo
      Ym4r::YahooMaps::BuildingBlock::Geocoding.get(:city => )
    end
  end
end
