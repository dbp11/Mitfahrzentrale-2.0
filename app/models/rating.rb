# encoding: utf-8
# = Rating
# Die Klasse Rating stellt die Möglichkeit eines Users dar, einen anderen User
# zu einer bestimmten Fahrt zu bewerten. Dabei gehört ein Bewerter immer
# zu einem Bewerteten und einem Trip. 
#
# == Datenfelder:
# * comment :string -- bewertender Freitext, den der User angeben kann
# * mark :integer -- Note von 1 bis 6 für die Güte der Fahrt
# * trip_id :integer -- Referenz auf den bewerteten Trip
# * receiver_id :integer -- Referenz auf den bewerteten User
# * author_id :integer -- Referenz auf den bewertenden User
# * created_at :datetime -- <i>Von Rails erstellt</i> Erstellung der Bewertung
# * updated_at :datetime -- <i>Von Rails erstellt</i> letzte Veränderung
#
# == Validierungen von Datenfeldern:
#
# <b>Presence_of_Validations:</b>
# Datenfelder dürfen nicht Null sein und müssen bei Erstellung ausgefüllt werden
# * Trip_Id
# * Receiver_Id 
# * Author_Id
#
# <b>Spezielle Validations</b>
# 
# * Mark -- darf nur mit Integerwerten zwischen inklusive 1 und 6 gefüllt werden
# * :no_double_rating -- Ein User darf einen Trip, den er schon bewertet hat, nicht noch einmal bewerten
# * :no_future_rating -- Es dürfen nur Trips bewertet werden, die schon stattgefunden haben
# * :no_self_rating -- Ein User darf sich nicht selbst zu einem Trip bewerten

class Rating < ActiveRecord::Base
  
  #:Beziehungen
  #Beziehung: trip_gets_rating
  belongs_to :trip
  #Beziehung: user_writes_rating
  belongs_to :author, :class_name =>"User"
  #Bziehung: user_gets_rating
  belongs_to :receiver, :class_name =>"User"

  

  #Validation
  validates_presence_of :trip_id, :receiver_id, :author_id
  validates_numericality_of :mark, :only_interger => true, :message => "Note kann nur ganze Zahl sein"
  validates_inclusion_of :mark, :in => 1..6, :message => "Note kann nur von 1 bis 6 verteilt werden"
  validate :no_double_rating, :no_future_rating, :no_self_rating


  # Validation, die vor Erstellung überprüft, ob schon ein Rating mit der übergebenen Trip-, Receiver- und Author-Id 
  # vorhanden ist
  #
  # @throws Error, falls true
  def no_double_rating
    self.trip.ratings.each do |r|
      if r.author == self.author and r.receiver == self.receiver
        errors.add(:field, 'Man kann einen User nicht zweimal für einen Trip bewerten!')
      end
    end
  end
  
  # Prüft vor Erstellung, ob der zu bewertende Trip schon stattgefunden hat
  #
  # @throws Error, wenn Trip noch nicht gefahren wurde
  def no_future_rating
    if self.trip.start_time > Time.now
      errors.add(:field, "Du bist noch nicht gefahren!")
    end
  end
  
  # Receiver Id darf nicht gleich Author Id sein. D.h. man darf sich nicht selbst bewerten
  #
  # @throws Error, wenn true
  def no_self_rating
    if self.author == self.receiver
      errors.add(:fields, "Man kann sich nicht selbst bewerten!")
    end
  end
  
  # Validation, die vor Erstellung überprüft, ob der Bewerter, der zu bewertende und der Trip übereinstimmen, also ob
  # der Bewerter, den zu bewertenden und Trip überhaupt bewerten darf. Die berechtigung bekommt der Bewerter indem er 
  # tatsächlich am Trip teilgenommen hat
  #
  # @throws Error, wenn User versucht einen Trip zu bewerten, an dem er nicht teilgenommen hat
  def authenticate_rater
    if !((self.trip.users.include?(self.receiver) and self.trip.users.include?(self.author)) or
        (self.trip.users.include?(self.receiver) and self.trip.user==self.author) or 
        (self.trip.users.include?(self.author) and self.trip.user==self.author))
      then errors.add(:field, "Keine Berechtigung diesen User für diese Fahrt zu bewerten!")
    end
  end


  # == Methoden für Controller




  #to String Methode für Ratings
  def to_s
    comment
  end

end
