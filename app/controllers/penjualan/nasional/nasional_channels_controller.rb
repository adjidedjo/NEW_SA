class Penjualan::Nasional::NasionalChannelsController < ApplicationController
  include RolesHelper
  before_action :authorize_user, :checking_params
  
  def all_channel
    @allchannel = Penjualan::Sale.channel_nasional_this_month(@date)
    render template: "penjualan/template_dashboard/channels"
  end

  private

  def checking_params
    if params[:date].nil?
      date = '1/'+Date.yesterday.month.to_s+'/'+Date.yesterday.year.to_s
      @date = (date.to_date + Date.today.strftime('%d').to_i) - 1
    else
      date = '1/'+params[:date][:month].to_s+'/'+params[:date][:year].to_s
      @date = (date.to_date + Date.today.strftime('%d').to_i) - 1
    end
  end

  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, initialize_brand)
  end
end