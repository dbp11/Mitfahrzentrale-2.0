class MessagesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Zugriff verweigert!"
    redirect_to messages_path
  end
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:error] = "Zugriff verweigert!"
    redirect_to messages_path
  end
  
  # GET /messages
  # Die IndexAction gibt gibt alle empfangenen Nachrichten des Nutzer aus
  # Zeitstempel und Anzahl der neuen Nachrichten werden für die Anzeige gebraucht
  def index
    # Alle empfangenen Nachrichten des Nutzers
    @messages = current_user.get_received_messages
    # Zeitstempel des letzten Aufrufs
    @last_delivery = current_user.last_delivery
    # Anzahl der Nachrichten, die der Nutzer noch nicht eingesehen hat
	  @latest_messages = current_user.get_latest_messages
    # Den Zeitstempel auf die aktuelle Zeit setzen
    current_user.last_delivery = Time.now
    current_user.save
  end

  # Gibt alle geschriebenen Nachrichten des Nutzers aus
  # @params Geschrieben Nachrichten des Nutzers
  def outbox
    @messages = current_user.get_written_messages
  end

  # GET /messages/1
  # Da wir alle Nachrichten komplett in der Übersicht haben ist es nicht erlaubt, eine Nachricht
  # im Detail zu betrachten
  def show
    redirect_to messages_url
  end

  # GET /messages/new
  # Neue Nachricht soll erstellt werden
  def new
    #Neues Message Objekt, ich als Writer gesetzt, check auf default
    @message = Message.new
	  @message.writer = current_user
    check = false
    #UserID wird aus Parameter gelesen und gesetzt, check auf true
	  if params[:uid]
		  @message.receiver = User.find(params[:uid])
      check=true
    end
    #Wenn tid mitgegeben wird, wird der Nachrichtenbetreff automatisch befuellt, check auf true
		if params[:tid]
			temp = Trip.find(params[:tid])
			@message.subject = "[["+ url_for(temp) + "|" + temp.get_start_city + " - " + temp.get_end_city + " " + temp.start_time.strftime("%d.%m.%y") +"]]"
    end
    # Wir schreiben eine reply Nachricht, die wir empfangen haben, check true
	  if params[:mid]
		temp = Message.find(params[:mid])
      if temp.receiver == current_user
		    @message.receiver = temp.writer
		    @message.subject = "RE: " + temp.subject.to_s
        check=true
      end
    end
    # Wenn check noch false ist, ist was falsch gelaufen und wir werden redirected
    if !check
      redirect_to messages_path
    end
  end

  # GET /messages/1/edit
  # Nachricht soll editiert werden
  # @params id die die Nachricht identifiziert
  def edit
    @message = Message.find(params[:id])
  end

  # POST /messages
  # Neue Nachricht wird erstellt
  def create
    @message = Message.new(params[:message])
    @message.delete_receiver = false
    @message.delete_writer = false

    if @message.save
      redirect_to messages_path, notice: 'Message was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /messages/1
  # Message wird geupdated
  def update
    @message = Message.find(params[:id])
    # "Loescht" der Empfaenger eine Nachricht, wird sie fuer ihn invisible
  	if params[:who] == "receiver"
	  	@message.delete_receiver = true
    # "Loescht" der Schreiber eine Nachricht, wird sie fuer ihn invisible
  	elsif params[:who] == "writer"
	  	@message.delete_writer = true
  	end
    @message.save
    # Haben Autor und Empfaenger einer Nachricht sie "geloescht" wird sie auch richtig aus der DB entfernt
	  if @message.delete_receiver and @message.delete_writer
  	   @message.destroy
  	end
    # Redirect je nachdem, "wer" wir sind
    if params[:who] == "writer"
      redirect_to "/messages/outbox", notice: 'Message was successfully deleted.'
    elsif params[:who] == "receiver"
      redirect_to messages_url, notice: 'Message was successfully deleted.'
    elsif
      redirect_to messages_url, notice: 'Message could not be deleted.'
    end
  end

  # DELETE /messages/1
  # Nachricht loeschen
  # @params id der zu loeschenden Nachricht
  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    redirect_to messages_url
  end
end
