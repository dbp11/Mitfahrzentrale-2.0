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
  # GET /messages.json
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
  def outbox
    @messages = current_user.get_written_messages
  end

  # GET /messages/1
  # GET /messages/1.json
  # Da wir alle Nachrichten komplett in der Übersicht haben ist es nicht erlaubt, eine Nachricht
  # im Detail zu betrachten
  def show
    redirect_to messages_url
  end

  # GET /messages/new
  # GET /messages/new.json
  def new
    @message = Message.new
	  @message.writer = current_user
    check = false
	  if params[:uid]
		  @message.receiver = User.find(params[:uid])
      check=true
    end
		if params[:tid]
			temp = Trip.find(params[:tid])
			@message.subject = "[["+ url_for(temp) + "|" + temp.get_start_city + " - " + temp.get_end_city + " " + temp.start_time.strftime("%d.%m.%y") +"]]"
      check=true
    end
	  if params[:mid]
		# message reply
		temp = Message.find(params[:mid])
      if temp.receiver == current_user
		    @message.receiver = temp.writer
		    @message.subject = "RE: " + temp.subject.to_s
        check=true
      end
    end
    if !check
      redirect_to messages_path
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])
  end

  # POST /messages
  # POST /messages.json
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
  # PUT /messages/1.json
  def update
    @message = Message.find(params[:id])
  	if params[:who] == "receiver"
	  	@message.delete_receiver = true
  	elsif params[:who] == "writer"
	  	@message.delete_writer = true
  	end
    @message.save
	  if @message.delete_receiver and @message.delete_writer
  	   @message.destroy
  	end
    if params[:who] == "writer"
      redirect_to "/messages/outbox", notice: 'Message was successfully deleted.'
    elsif params[:who] == "receiver"
      redirect_to messages_url, notice: 'Message was successfully deleted.'
    elsif
      redirect_to messages_url, failure: 'Message could not be deleted.'
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    redirect_to messages_url
  end
end
