# encoding: utf-8

# Modelliert alle Nachrichten, die ein User schreibt oder bekommt
#
# ===Das Model hat die Datenfelder
#
# * message_id   :integer -- <i>Von Rails erstellt.</i> ID der Nachricht
# * message      :text    -- Nachricht
# * writer_id    :integer -- user_id des Schreibers
# * receiver_id  :integer -- user_id des Empfängers
# * created_at   :datetime -- <i>Von Rails erstellt.</i> Erstellungsdatum des Objekts
# * updates_at   :datetime -- <i>Von Rails erstellt.</i> letztes Änderungsdatum des Objekts
# * delete_writer :boolean -- true, wenn die Nachricht beim Schreiber nicht mehr angezeigt werden soll, false sonst
# * delete_receiver :boolean -- true, wenn die Nachricht bei Empfänger nicht mehr angezeit werden soll, false sonst
# * subject      :string   -- Betreff der Mail
#
# ===Das Model Messages hat folgende Validations:
#
# <b>validates_presence_of</b> ("Datenfelder dürfen nicht Null sein, bzw. müssen beim anlegen eines neuen Autos ausgefüllt werden")
#
# * :message
# * :subject
# * :writer_id
# * :receiver_id
#
# <b>validates_length_of</b> ("Datenfelder müssen eine bestimmte Länge haben, oder dürfen nicht Länger sein als x")
#
# * :subject --  ("Betreff muss 1 bis 120 Zeichen lang sein")
# * :message --  ("Nachricht muss 1 bis 2000 Zeichen lang sein")
#
# <b>validate</b> ("eigene Validation_Methoden, Beschreibung bei den jeweiligen Methoden")
#
# * :no_true_true
# * :delete_writer_nil
# * :delete_receiver_nil
#
# ===Beziehungen
#
# * belongs_to :writer ("class_name User, ein writer ist ein Userobjekt")
# * belongs_to :receiver ("class_name User, ein receiver ist ein Userobjekt")

class Message < ActiveRecord::Base
  include ActiveModel::Validations 
     
#############################   Beziehungen   ############################
  
  

  #Beziehungen:
  #Beziehung:users_write_messages
  belongs_to  :writer, :class_name => "User"
  #Beziehung:users_receive_messages
  belongs_to  :receiver, :class_name => "User"
 


#############################   Validations   ############################
  
  
  validates_length_of :subject, :in => 1..120
  validates_length_of :message, :in => 1..2000
  validate :no_true_true, :delete_writer_nil, :delete_receiver_nil
  validates_presence_of :message, :subject, :writer_id, :receiver_id 
  
  # Methode prüft ob eine Message bei delete_writer und delete_receiver true ist. Falls dies der Fall ist wollen Empfänger und Schreiber sich die Nachricht nicht mehr anzeigen lassen, d.h. die Nachricht kann aus der Datenbank gelöscht werden
  #
  # @throws Message kann gelöscht werden
  def no_true_true
    if (self.delete_writer? and self.delete_receiver?)
      errors.add(:field, 'Nachricht wird gelöscht!')
    end
  end
  
  # delete_writer darf nicht Null werden
  def delete_writer_nil
    if(self.delete_writer == nil)
      errors.add(:field, 'delete_writer nil')
    end
  end

  # delete_receiver darf nicht Null werden
  def delete_receiver_nil 
    if(self.delete_receiver == nil)
      errors.add(:field, 'delete_receiver nil')
    end
  end


########################   Methoden für Controller   #######################


  # to_String Methode für Message
  def to_s  
    writer.to_s+ " an " +receiver.to_s+ ": " +message
  end
end
