# encoding: utf-8


# Modelliert alle Autos, die ein User hat
#
# ===Das Model hat die Datenfelder:
#
# * car_id      :integer  -- <i>Von Rails erstell.</i> ID des Autos
# * user_id     :integer  -- ID des Users, der das Auto besitzt
# * seats       :integer  -- Sitzplätze, die das Auto hat
# * licence     :string   -- Nummernschild
# * smoker      :boolean  -- Raucher oder Nichtraucherauto
# * created_at  :datetime -- <i>Von Rails erstellt.</i> Erstellungsdatum des Objekts
# * updated_at  :datetime -- <i>Von Rails erstellt.</i> letztes Änderungsdatum des Objekts
# * description :string   -- Bezeichnung vom Auto. (z.B. Klimaanlage ...)
# * carpic_file_name :string -- <i>Von Paperclip gefordertes Datenfeld</i>
# * carpic_content_type :string -- <i>Von Paperclip gefordertes Datenfeld</i>
# * carpic_file_size :integer -- <i>Von Paperclip gefordertes Datenfeld</i>
# * carpic_updates_at :datetime -- <i>Von Paperclip gefordertes Datenfeld</i>
# * car_type :text -- Datenfeld zum Autotyp (z.B BMW 3er, Audi TT ...)
# * price_km :float -- vom User erwarteter Preis auf 100 Km (kann auch Null sein)
#
# ===Das Model Cars hat folgende Validations:
#
# <b>validates_presence_of</b> ("Datenfelder dürfen nicht Null sein, bzw. müssen beim Anlegen eines neuen Autos ausgefüllt werden")
#
# * :seats
# * :licence
# * :car_type
# * :user_id
# 
# <b>validates_numericality_of</b> ("Datenfelder müssen aus Zahlen bestehen, damit sichergestellt wird, dass man mit dieser Angabe weiterrechnen kann")
# 
# * :price_km
# 
# <b>validates_length_of</b> ("Datenfelder müssen eine bestimmte Länge haben, oder dürfen nicht länger sein als x")
#
# * :description -- ("0-160 Zeichen")
#
# <b>validates</b> 
# 
# * :licence -- <i>uniqueness</i> ("Nummernschild muss einzigartig sein"), <i>presence</i> ("muss vorhanden sein, also nicht Null"), <i>length ("1-10")</i> ("muss Länge zwischen 1 bis 10 haben")
#
# ===Beziehungen
#
# * belongs_to :user ("ein Auto gehört immer genau zu einem User")
# * has_many :trips  ("ein Auto kann mehrere Trips fahren")

class Car < ActiveRecord::Base
  
#############################   Beziehungen   ############################
  belongs_to :user
  has_many :trips


#############################   Validations   ############################
  
  
  #Kontrolle ob das Kennzeichen eine Gülitige Länge hat
  validates :licence, :uniqueness => true, :presence => true, :length => {:in => 1..10}

  #Validation ein Auto muss ein Nummernschild, Bezeichnung und Sitzplätze haben
  validates_presence_of :seats, :licence, :car_type, :user_id 
  
  validates_numericality_of :price_km, :message => "Deine Eingabe muss aus Zahlen bestehen"
  validates_length_of :description, :in => 0..160
  


########################   Methoden für Controller   #######################
  
  

  #Von Paperclip gefordertes Statement zum Anhängen von Bildern
  has_attached_file :carpic, :styles => { :medium =>  "400x400>", :thumb => "100x100>"}

  #to String Methode für Cars
  def to_s
    "Besitzer: " + user + "\n" +
    "Typ:" + description + "\n" +
    "Plätze: " + seats + "\n" +
    "Kofferraum: " + trunk + "\n" +
    "Verbrauch: " + fuel_consumption + "\n" +
    "Nummernschild: " + licence + "\n" +
    "Raucher: " + smoker? ? "ja" : "nein"
  end
  

  #Methode gibt true zurück, wenn dieses Auto in einem noch kommenden Trip verwendet wird,
  #false sonst
  def is_used
    self.user.to_drive.each do |d|
      if d.car == self
        return true
      end
    end
    return false
  end

end
