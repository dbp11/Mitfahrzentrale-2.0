require 'spec_helper'

describe Trip do
  before(:each) do
    @attr = {
      :user_id => 4564,
      :car_id => 545,
      :starts_at_N => 12,
      :starts_at_E => 35,
      :ends_at_E => 45,
      :ends_at_N => 5,
      :start_city => "fesfe",
      :start_street => "efsfe",
      :start_zipcode => 4564,
      :end_city => "dee",
      :end_street => "edsfes",
      :end_zipcode => 4456,
      :start_time => Time.now,
      :comment => "fejskfsbnfjkfesfse",
      :baggage => true,
      :free_seats => 4
    }
  end
  
  #Test ob Validations funktionieren
  it "Kontrolle ob Validation start_city funktioniert" do
    no_address_start = Trip.new(@attr.merge(:start_city => nil))
    no_address_start.should_not be_valid
  end

  it "Kontrolle ob Validation end_city funktioniert" do
    no_address_end = Trip.new(@attr.merge(:end_city => nil))
    no_address_end.should_not be_valid
  end


  #Test ob Methoden funktionieren
end
