class EventsController < ApplicationController
  before_action :authenticate

  def index
  end

  def show
    if Event.exists?(params[:id])
      @event = Event.find(params[:id])
    else
      redirect_to Event, alert: 'ご指定のイベントは存在しません。'
    end
  end

  def new
    @event = User.find(session[:user_id]).created_events.build
  end

  def create
    @event = User.find(session[:user_id]).created_events.build(event_params)

    if @event.save
      redirect_to @event, notice: '作成しました。'
    else
      render :new
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :place, :start_time, :end_time, :content)
  end
end
