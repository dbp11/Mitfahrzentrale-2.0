class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role == "member"
      can [:index], :all
      can :create [Car, Message, Request, Trip, User]
        
      can [:show, :update, :destroy], Car do |car|
        car && car.user == user 
      end
      can :show, user.get_visible_cars

      can [:outbox, :show, :update, :destroy], Message do |message|
        message && message.writer == user
      end
      can [:show, :destroy], Message do |message|
        message && message.receiver == user
      end

      can [:show, :update, :destroy], Request do |request|
        request && request.user == user
      end

      can :show, Trip
      can [:update, :destroy], Trip do |trip|
        trip && trip.user == user
      end

      can :create, user.can_rate
      can [:show, :update, :destroy], Rating do |rating|
        rating && rating.author == user
      end
      can :show, Rating do |rating|
        rating && rating.receiver == user
      end

      can :show, user.get_visible_users
      can [:show, :update, :destroy], User do |user1|
        user1 && user1 == user
      end

    elsif user.role == "admin"
      can :manage, :all
    end

    #can ...
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end

