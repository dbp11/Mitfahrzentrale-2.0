class MessagesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Zugriff verweigert!"
    redirect_to messages_url
  end
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:error] = "Zugriff verweigert!"
    redirect_to messages_url
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

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end

  # Gibt alle geschriebenen Nachrichten des Nutzers aus
  def outbox
    @messages = current_user.get_written_messages

    respond_to do |format|
      format.html # index.html.haml
      format.json  { render :json => @messages }
    end
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


    respond_to do |format|
      if @message.save
        format.html { redirect_to messages_path, notice: 'Message was successfully created.' }
        format.json { render json: @message, status: :created, location: @message }
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
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
    respond_to do |format|
      if params[:who] == "writer"
        format.html { redirect_to "/messages/outbox", notice: 'Message was successfully deleted.' }
        format.json { head :ok }
      elsif params[:who] == "receiver"
        format.html { redirect_to messages_url, notice: 'Message was successfully deleted.' }
        format.json { head :ok }
      else
        format.html { redirect_to messages_url, failure: 'Message could not be deleted.' }
        format.json { head :ok }
	    end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url }
      format.json { head :ok }
    end
  end
end
