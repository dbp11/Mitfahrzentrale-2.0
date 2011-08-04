# encoding: utf-8

class Rating < ActiveRecord::Base
  
#############################   Beziehungen   ############################
  #:Beziehungen
  #Beziehung: trip_gets_rating
  belongs_to :trip
  #Beziehung: user_writes_rating
  belongs_to :author, :class_name =>"User"
  #Bziehung: user_gets_rating
  belongs_to :receiver, :class_name =>"User"

#############################   Validations   ############################
  

  #Validation
  validates_presence_of :trip_id, :receiver_id, :author_id
  validates_numericality_of :mark, :only_interger => true, :message => "Note kann nur ganze Zahl sein"
  validates_inclusion_of :mark, :in => 1..6, :message => "Note kann nur von 1 bis 6 verteilt werden"
  validate :no_double_rating, :authenticate_rater, :no_future_rating, :no_self_rating

  def no_double_rating
    self.trip.ratings.each do |r|
      if r.author == self.author and r.receiver == self.receiver
        errors.add(:field, 'Man kann einen User nicht zweimal für einen Trip bewerten!')
      end
    end
  end
  
  def no_future_rating
    if self.trip.start_time > Time.now
      errors.add(:field, "Du bist noch nicht gefahren!")
    end
  end
  
  def no_self_rating
    if self.author == self.receiver
      errors.add(:fields, "Man kann sich nicht selbst bewerten!")
    end
  end
  
  def authenticate_rater
    if !(self.trip.users.include?(author) and self.trip.user == receiver or
         self.trip.users.include(receiver) and self.trip.user == author)
      then errors.add(:field, "Keine Berechtigung diesen User für diese Fahrt zu bewerten!")
    end
  end
########################   Methoden für Controller   #######################

  #to String Methode für Ratings
  def to_s
    comment
  end

end
