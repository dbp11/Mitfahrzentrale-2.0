# = Die Klasse User
# Das User-Modell stellt den Dreh und Angelpunkt unseres Datenbanksystems dar. Mit ihm werden Trips und Gesuche 
# erstellt, Messages versandt, Ratings gegeben, an ihm die Profileinstellungen gespeichert. Folglich ist der User, 
# in hinsicht der Beziehungen, die komplexeste Klasse.
# Er besitzt folgende Datenfelder:
# * email :string -- E-Mail Adresse des Benutzers
# * encrypted_password :string -- verschlüsseltes Passwort des Benutzers (Devise Plugin)
# * reset_password_token :string -- Zurücksetzen des Passwortkürzels
# * reset_password_sent_at :datetime -- letztes Zurücksetzen des Passwort
# * remember_created_at :datetime -- Remember_Me Anlage am
# * sign_in_count :integer -- Anzahl der Logins
# * current_sign_in_at :datetime -- Aktuell eingeloggt um
# * last_sign_in_at :datetime -- Zuletzt eingeloggt am
# * created_at :datetime -- <i>Von Rails automatisch angelegt:</i> Erstellungsdatum des Users
# * updated_at :datetime -- <i>Vom Rails automatisch angelegt:</i> Letztes Update an den Datenfeldern
# * name :string -- Nutzername
# * user_type :boolean -- Adminrechte ja/nein
# * sex :boolean -- false weiblich, true männlich
# * address :string -- Straße, Hausnummer
# * addressN :float -- <i>Von Geocoder benötigt:</i> nördliche Breite der Adresse 
# * addressE :float -- <i>Von Geocoder benötigt:</i> östliche Länge der Adresse
# * zipcode :integer -- Postleitzahl
# * instantmessenger :string -- Instantmessenger
# * city :string Wohnort
# * birthday :date -- Geburtsdatum des Users 
# * phone :string Telephonnummer
# * business :boolean -- Ist User Gewerbs- oder Privatanbieter
# * email_notifications -- E-Mail-Benachrichtigungen an- oder ausschalten
# * visible_phone :boolean -- Sichtbarkeit der Telephonnummer an- oder ausschalten
# * visible_email :boolean -- Sichtbarkeit der E-Mail an- oder ausschalten
# * visible_address :boolean -- Sichtbarkeit der Adresse an- oder ausschalten
# * visible_age :boolean -- Sichtbarkeit des Alter an- oder ausschalten
# * visible_im :boolean -- Sichtbarkeit des Instantmessenger an- oder ausschalten
# * visible_cars :boolean -- Sichtbarkeit der Autos an- oder ausschalten
# * visible_zip :boolean -- Sichtbarkeit der Postleitzahl an- oder ausschalten
# * visible_city :boolean -- Sichtbarkeit der Stadt an- oder ausschalten
# * picture_file_name :string -- <i>Von Paperclip gefordert</i> Name des gespeicherten Bildes
# * picture_content_type :string -- <i>Von Paperclip gefordert</i> Dateityp des Bildes
# * picture_file_size :integer -- <i>Von Paperclip gefordert </i> Größe des Bildes
# * picture_updated_at :datetime -- <i>Von Paperclip gefordert </i> letzte Bildänderung
class User < ActiveRecord::Base

  ####################### ==Railsplugin Devise ################################
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, 
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, 
    :remember_me, :address, :zipcode, :birthday, :city, :sex, :phone, 
    :instantmessenger, :visible_age, :visible_address, :visible_zip, 
    :visible_phone, :visible_city, :visible_im, :visible_email, :visible_cars, :last_delivery, :user_type, :email_notifications, :business, :last_ratings, :role 
  #Von Paperclip gefordertes Statement zum Anhängen von Bildern
  has_attached_file :pic, :styles => { :medium =>  "300x300>", 
                                           :thumb => "100x100>"}

before_validation :set_member, :set_last_delivery_ratings 
  #before_save {|user| user.role = "member" if user.role.blank?} 
  def set_last_delivery_ratings
    if last_delivery.nil?
      self.last_delivery = Time.now
    end
    if self.last_ratings.nil?
      self.last_ratings = Time.now
    end
  end

  def set_member
    if (self.role != "admin")
      self.role = "member"
    end
  end

  ############################ ==Validations: #################################
  # Stat. Integrität: Email muss vorhanden, unique und min 8 char lang sein
  # Name, Adresse, Plz, Stadt müssen vorhanden sein
  # Die boolschen Datenfelder zur Bestimmung der Sichtbarkeiten müssen gesetzt 
  # sein, also nicht Null
  validates :email, :uniqueness => true, :presence => true, 
  :length => {:minimum => 8}
  validates_presence_of :name, :address, :zipcode, :city 
  validate :booleans_not_nil, :role_member_admin

  private # die Validation-Methoden private

  def booleans_not_nil 
    user_type_not_nil
    sex_not_nil 
    email_notifications_not_nil 
    visible_phone_not_nil  
    visible_email_not_nil 
    visible_address_not_nil 
    visible_age_not_nil 
    visible_im_not_nil 
    visible_cars_not_nil 
    visible_zip_not_nil  
    visible_city_not_nil 
    business_not_nil 
  end

  def user_type_not_nil
    if self.user_type.nil?
      errors.add(:field, 'user_type darf nicht nil sein!')
    end
  end

  def sex_not_nil
    if self.sex.nil?
      errors.add(:field, 'sex darf nicht nil sein!')
    end
  end

  def email_notifications_not_nil
    if self.email_notifications.nil?
      errors.add(:field, 'email_notifications darf nicht nil sein!')
    end
  end

  def visible_phone_not_nil
    if self.visible_phone.nil?
      errors.add(:field, 'visible_phone darf nicht nil sein!')
    end
  end

  def visible_email_not_nil
    if self.visible_email.nil?
      errors.add(:field, 'visible_email darf nicht nil sein!')
    end
  end

  def visible_address_not_nil
    if self.visible_address.nil?
      errors.add(:field, 'visible_address darf nicht nil sein!')
    end
  end

  def visible_age_not_nil
    if self.visible_age.nil?
      errors.add(:field, 'visible_age darf nicht nil sein!')
    end
  end

  def visible_im_not_nil
    if self.visible_im.nil?
      errors.add(:field, 'visible_im darf nicht nil sein!')
    end
  end

  def visible_cars_not_nil
    if self.visible_cars.nil?
      errors.add(:field, 'visible_cars darf nicht nil sein!')
    end
  end

  def visible_zip_not_nil
    if self.visible_zip.nil?
      errors.add(:field, 'visible_zip darf nicht nil sein!')
    end
  end

  def visible_city_not_nil
    if self.visible_city.nil?
      errors.add(:field, 'visible_city darf nicht nil sein!')
    end
  end

  def business_not_nil
    if self.business.nil?
      errors.add(:field, 'business darf nicht nil sein!')
    end
  end

  def role_member_admin
    if(self.role!='admin' and self.role!='member')
      errors.add(:field, 'Role muss entweder admin oder member sein!')
    end
  end


  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :address, :zipcode, :birthday, :city, :sex, :phone, :instantmessenger, :visible_age, :visible_address, :visible_zip, :visible_phone, :visible_city, :visible_im, :visible_email, :visible_cars, :pic_file_size, :pic_file_name, :pic_content_type, :pic_update_at, :business, :pic, :role 
  
  
  # Von Paperclip gefordertes Statement zum Anhängen von Bildern
  has_attached_file :pic, :styles => { :medium =>  "300x300>", :thumb => "500x500>"}


 
  
  ############################# ==Beziehungen:#################################
  # Beziehung vom Modell User zu Trip über die Joinrelation Passengers 
  # (:through => Passengers) als passenger_trips
  has_many :passenger_trips, :class_name => "Trip", :through => :passengers, 
    :source => :trip
  # Beziehung vom User zu Trip, wobei der User hier, anders als bei
  # Passenger_Trips nicht Mitfahrer, sondern Fahrer ist
  has_many :driver_trips, :class_name => "Trip", :foreign_key => "user_id" 
  has_many :cars, :dependent => :destroy
  # Beziehung von User zur Jointable Passengers - Diese Relation ist notwendig 
  # um zu überprüfen, ob ein User als Mitfahrer akzeptiert oder abgelehnt wurde
  has_many :passengers, :dependent => :destroy
  # Beziehung vom User zu Requests. Requests stellen die Gesuche dar, also
  # Strecken, die man als Nutzer gerne als Mitfahrer begehen würde. 
  has_many :requests, :dependent => :destroy
  # Selbstreferenzierende Beziehung User ignores User
  # Bei dieser Relation wird ein User mit einem anderen User in der Jointable
  # Ignores in Beziehung gesetzt.
  # Die Jointable Ignores hat kein eigenes Model, nur eine Migration, d.h. alle
  # Methoden werden über den User abgewickelt
  has_and_belongs_to_many :ignorings, :class_name => "User", :join_table  => "ignore", :foreign_key =>
  "ignored_id", :association_foreign_key => "ignoring_id"  
  has_and_belongs_to_many :ignoreds, :class_name => "User", :join_table => "ignore", :foreign_key =>
  "ignoring_id", :association_foreign_key => "ignored_id"
  # Beziehung User schreibt User Nachricht/Rating
  # Anders als bei der selbstreferenzierenden User_ignores_User-Beziehung
  # müssen für die Beziehungen Message und Rating
  # jeweils eigene Modellklassen erstellt werden, da diese zusätzlich einen
  # Text als Datenfeld besitzen, d.h. 
  # die Klassen Message und Rating funktionieren als "Joinentitäten" für die
  # Klasse User.
  has_many :received_messages, :class_name => "Message", :foreign_key =>"receiver_id", :dependent => :destroy
  has_many :written_messages,  :class_name => "Message", :foreign_key =>"writer_id", :dependent => :nullify
  has_many :written_ratings, :class_name => "Rating", :foreign_key => "author_id", :dependent => :nullify
  has_many :received_ratings, :class_name => "Rating", :foreign_key => "receiver_id", :dependent => :destroy

  ROLES = %w[admin member]

  public # ab hier wieder public
  # == Methoden
  # toString Methode für User
  # @return Name des Users
  def to_s
    name
  end
  
  # Vergangene angebotene Trips des Users
  # @return Trip [] erg
  def driven
   erg=[] 
   driver_trips.each do |x|
     if x.start_time < Time.now
       then erg = erg << x
     end
   end
   return erg.sort{|a,b| b.start_time <=> a.start_time}
  end

  # Noch nicht vergangene angebotene Trips des Users
  # return Trip [] erg
  def to_drive
    erg=[]
    driver_trips.each do |x|
      if x.start_time > Time.now
        then erg = erg << x
      end
    end
    return erg.sort{|a,b| a.start_time <=> b.start_time}
  end

  # Vergangene Suchen des Users
  # @return Trip [] erg
  def driven_with
    erg=[]
    passenger_trips.each do |x|
      if x.start_time < Time.now
        then erg = erg << x
      end
    end
    return erg.sort{|a,b| b.start_time <=> a.start_time}
  end

  # Noch laufende Suchen des Users
  # @return Trip [] erg
  def to_drive_with
    erg=[]
    passenger_trips.each do |x|
      if x.start_time > Time.now
        then erg = erg << x
      end
    end
    return erg.sort{|a,b| a.start_time <=> b.start_time}
  end

  # Liefert alle Trips des Users zurück, bei denen er sich um Mitfahrt
  # beworben hat
  # @return Trip [] erg
  def applied_at
    erg =[]
    self.passengers.each do |p|
      if p.start_time > Time.now and !p.confirmed?
        erg = erg << p.trip
      end
    end
    erg
  end

  # Methode zur Ermittlung des durchschnittlichen Ratings des Users 
  # @return float 3, wenn User noch keine
  # Bewertungen hat
  # @return float Sum(Ratings)/Anz(Ratings)
  def get_avg_rating
    count = count_ratings
    if count == 0
      return 3
    end

    erg = 0
    self.received_ratings.each do |x|
        erg = erg + x.mark
    end

      return (erg.to_f / count_ratings).round(1)
  end


  # Methode zur Ermittlung des durchschnittlichen Ratings des Users als Fahrer
  # @return float 3, wenn User noch keine Bewertungen als Fahrer hat
  # @return float Sum(Ratings)/Anz(Ratings)
  def get_avg_rating_driver
    count = count_ratings_driver
    if count == 0
      return 3
    end

    erg = 0
    self.driven.each do |d|
      d.ratings.each do |r|
        if r.receiver == self
          erg += r.mark
        end
      end
    end
    
    return (erg.to_f / count).round(1)
  end

  # Methode zur Ermittlung des durchschnittlichen Ratings des Users als
  # Mitfahrer
  # @return float 3, wenn User noch keine Bewertungen als Mitfahrer hat
  # @return float Sum(Ratings)/Anz(Ratings)
  def get_avg_rating_passenger
    count = count_ratings_passenger
    if count == 0
      return 3
    end

    erg = 0
    self.driven_with.each do |d|
      d.ratings.each do |r|
        if r.receiver == self
          erg += r.mark
        end
      end
    end
    
    return (erg.to_f / count).round(1)
  end


  # Methode, die alle Erhaltenen Ratings des Users zählt
  # @return integer count
  def count_ratings
    self.received_ratings.count
  end

  # Methode, die nur die Ratings zählt, wo der User Fahrer war
  # @return integer count
  def count_ratings_driver
    count = 0
    self.driven.each do |d|
      d.ratings.each do |r|
        if r.receiver == self
          count += 1
        end
      end
    end
    return count
  end

  # Methode, die nur die Ratings zählt, wo der User Mitfahrer war
  # @return integer count
  def count_ratings_passenger
    count = 0
    self.driven_with.each do |d|
      d.ratings.each do |r|
        if r.receiver == self
          count += 1
        end
      end
    end
    return count
  end

  # Methode, die alle gesendeten Nachrichten eines Users, die nicht gelöscht
  # sind, zurückliefert
  # @return Message [] absteigend sortiert nach Datum
  def get_written_messages
    erg = []
    self.written_messages.each do |m|
      if !m.delete_writer? then
        erg << m
      end
    end
    erg.sort{|a,b| b.created_at <=> a.created_at}
  end

  # Methode, die alle empfangenen Nachrichten eines Users, die nicht gelöscht
  # sind, zurückliefert
  # @return Message [] absteigend sortiert nach Datum
  def get_received_messages
    erg = []
    self.received_messages.each do |m|
      if !m.delete_receiver? then
        erg << m
      end
    end
    erg.sort{|a,b| b.created_at <=> a.created_at}
  end
  
  # Methode, die die relative Anzahl an Ignorierungen eines Users zurückliefert
  # @return float Ignorierungen_des_Users / Anz(User)
  def get_relative_ignorations
    self.ignoreds.count.to_f / User.all.count.to_f
  end
  
  # Methode, die alle für den User sichtbaren Autos zurückliefert.
  # Wenn ein User bei einem Trip Mitfahrer ist, so wird das Auto das Fahrers
  # für ihn sichtbar
  # @return Car Set
  def get_visible_cars
    erg = []
    Trip.all.each do |t|
      if t.start_time > Time.now
        erg << t.car
      end
    end
    return erg
  end

  # Methode, die alle für einen User sichtbaren User zurückliefert
  # User werden sichtbar, wenn der Benutzer mit diesen über einen Trip in
  # verbindung gebracht werden kann
  # @return User [] 
  def get_visible_users
    erg = Array.new
    self.passengers.each do |p|
      if p.confirmed? and p.trip.start_time > Time.now
        p.trip.users.each do |u|
          erg << u
        end
      end
      erg << p.trip.user
    end
    self.driver_trips.each do |d|
      if d.start_time > Time.now
        d.users.each do |u|
          erg << u
        end
      end
    end
    return erg
  end
  
  # Methode, die die zurückgelegte Distanz als Mitfahrer in <i>m</i> zurückgibt
  # @return gesammte als aktueller Mitfahrer zurückgelegte Distanz
  def toured_distance_p
    distance = 0
    self.driven_with.each do |t|
      distance += t.distance
    end
    distance
  end

  # Methode, die die als Mitfahrer gefahrene Zeit in <i>s</i> zurückgibt
  # @return gesammte als aktueller Mitfahrer gefahrene Zeit
  def toured_time_p
    time = 0
    self.driven_with.each do |t|
      time += t.duration
    end
    time
  end
  
  # Methode, die die als Fahrer zurückgelgte Distanz in <i>m</i> zurückgibt
  # @return gesammte als Fahrer zurückgelgete Distanz
  def toured_distance_d
    distance = 0
    self.driven.each do |t|
      distance += t.distance
    end
    distance
  end
  
  # Methode, die die asl Fahrer gefahrene Zeit in <i>s</i> zurückgibt
  # @return gesammte als Fahrer gefahrene Zeit
  def toured_time_d
    time = 0
    self.driven_trips.each do |t|
      time += t.duration
    end
    time
  end
  
  # Methode die ermittelt, ob der aktuelle User vom übergebenen User zum
  # übergebenen Trip schon bewertet wurde
  # @param User rater
  # @param Trip trp
  # @return false, wenn noch keine Bewertung abgegeben wurde
  # @return true, wenn eine Bewertung abgegeben wurde
  def allready_rated (rater, trp)
    check = false
    rater.written_ratings.each do |r|
      if r.receiver_id == self.id and r.trip_id == trp.id 
        check = true
      end
    end
    check
  end

  # Methode, die ermittelt, ob dieser User den übergebenen User usr bezüglich des 
  # übergebenen Trips trp bewerten darf
  # @param User usr
  # @param Trip trp
  # @return true, wenn er bewerten darf, false sonst
  def allowed_to_rate (usr, trp)
    !usr.nil? and !trp.nil? and trp.finished and 
    (trp.users.include? self or trp.user == self) and
    (trp.users.include? usr or trp.user == usr) and
    self != usr and
    Rating.where("trip_id = ?", trp.id).where("author_id = ?", self.id).where("receiver_id = ?", usr.id).empty?
  end
   
  
  def get_waiting_ratings
    erg = []
    trps = driven_with + driven
    trps.each do |t|
      t.get_committed_passengers.each do |u|
        if allowed_to_rate u, t
          erg << [u, t]
        end
      end
      if allowed_to_rate t.user, t
        erg << [t.user, t]
      end
    end

    erg
  end
  

  #Lässt einen User sich um eine Mitfahrgelegenheit bewerben
  #@param Trip trp um den sich beworben werden soll
  #@return false, wenn der User sich schon auf den Trip beworben hat
  #@return false, wenn eine Validatierung beim Einspeichern des Users eine
  #Verletzung der Integrität feststellt
  #@return true, wenn Einspeichern funktioniert hat
  def bewerben (trp)
      if self.passengers.where("user_id = ?", self.id).where("trip_id = ?", trp.id).count > 0
        false
      else
        begin
        self.passengers.new(user_id: self.id, trip_id: trp.id, confirmed: false).save 
        rescue Error
          false
        end
      end
  end    
 
  # Methode, die alle Ratings liefert, die der User erstellt hat 
  # @return rating [] sortiert nach Datum
  def get_own_written_ratings
    self.written_ratings.sort{|a,b| b.created_at <=> a.created_at}[0..4]
  end

  # Methode, die alle Ratings liefert, die dieser User als Fahrer erhalten hat
  # @return rating [] sortiert nach Datum
  def get_own_driver_ratings
    erg = []
    self.received_ratings.each do |r|
      if r.trip.user == self
        erg << r
      end
    end
    erg.sort{|a,b| b.created_at <=> a.created_at}[0..4]
  end

  # Methode, die alle Ratings liefert, die dieser User als Mitfahrer erhalten
  # hat
  # @return rating [] sortiert nach Datum
  def get_own_passenger_ratings
    erg = []
    self.received_ratings.each do |r|
      if r.trip.users.include?(self)
        erg << r
      end
    end
    erg.sort{|a,b| b.created_at <=> a.created_at}[0..4]
  end
  

  # Liefert die Anzahl der Nachrichten zurück, die der User noch nicht
  # eingesehen hat.
  # @return integer count
  def get_latest_messages
    count = 0
    self.received_messages.each do |m|
      if m.created_at >  self.last_delivery
        count+=1
      end
    end
    count
  end    
  
  # Liefert die Anzahl der Ratings zurück, die der User noch nicht eingesehen
  # hat.
  # @return integer count
  def get_latest_ratings
    count = 0
    self.received_ratings.each do |m|
      if m.created_at > self.last_ratings
        count+=1
      end
    end
    count
  end   


  
  # Methode, die alle eigenen Requests zurückliefert
  #
  # @return Request []
  def get_own_requests
    self.requests
  end
  
  # Fügt einen übergebenen User in die User ignores User Relation ein. D.h.der User wird vom System ab sofort als
  # ignoriert gewertet
  #
  # @param User, der ignoriert werden soll
  # @return true, wenn Einfügen in Ignorerelation geklappt hat
  # @return false, sonst
  def ignore (usr)
    if !self.ignorings.include?(usr) and self != usr
      self.ignorings << usr
      true
    else
      false
    end
  end
  
  # Methode, um einen bereits ignorierten User wieder aus der Ignorerelation herauszunehmen, d.h. er wird nicht
  # ignoriert
  #
  # @param User, der nicht mehr ignoriert werden soll
  # @return true, wenn Löschen aus der Relation geklappt hat
  # @return false, sonst
  def unignore (usr)
    if self.ignorings.include?(usr)
      self.ignorings.delete(usr)
      true
    else
      false
    end
  end
 
  # Überprüft, ob User bereits ignoriert wird
  #
  # @param User, von dem der "Ignorestatus" überprüft werden soll
  # @return true, wenn User bereits ignoriert wird
  # @return false, wenn User nicht ignoriert wird
  def is_ignored (usr)
    if self.ignorings.include?(usr)
      true
    else
      false
    end
  end

end
