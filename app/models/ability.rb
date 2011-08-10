class Ability
  include CanCan::Ability
  # Implementiert das CanCan-Gem und spezifiziert die Rechteverwaltung der 
  # angemeldeten User und trifft hierbei eine Unterscheidung zwischen einen 
  # Member und dem Admin
  def initialize(user)
    if user.role == "member"
      can :index, :all
      can :create, :all
      #cannot :index, Home
      # Jeder Member kann jede Übersicht außer der Übersicht der User sehen
      # und kann alle Elemente erstellen
      can [:show, :update, :destroy], Car do |car|
        car && car.user == user 
      end
      can :show, user.get_visible_cars
      # Member können eigene Autos erstellen, editieren und zerstören und alle eigenen und bei teilzunehmenden Fahrten genutzten Autos anschauen 
      can [:outbox, :show, :update], Message do |message|
        message && message.writer == user
      end
      can [:show, :update], Message do |message|
        message && message.receiver == user
      end
      cannot [:edit], Message do |message|
        message && message.receiver == user
      end
      # Member können alle mit ihnen in Verbindung stehenden Messages lesen und editieren
      can [:show, :update, :destroy], Request do |request|
        request && request.user == user
      end
      # Member haben kompletten Zugriff auf die eigenen Anfragen
      can :show, Trip
      can [:update, :destroy], Trip do |trip|
        trip && trip.user == user
      end
      # Member können alle Fahrten sehen, jedoch nur die eigenen verändern
      can [:update, :destroy], Rating do |rating|
        rating && rating.author == user
      end
      # Member können nur selbstgeschriebene Ratings verändern
      can :show, user.get_visible_users
      can [:show, :update, :destroy], User do |user1|
        user1 && user1 == user
      end
      # Member können alle User sehen mit denen sie eine Fahrt antreten wollen und ihren eigenen Account verändern

      # Rechte der Member
    elsif user.role == "admin"
      can :manage, :all
      # Der Admin hat vollständige Zugriffsrechte
    end
  end
end
