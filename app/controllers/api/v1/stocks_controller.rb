module Api
  module V1
    class StocksController < ActionController::Base
      include PagerApi::Pagination::Kaminari
      
      def stock_normal
        @stocks = Stock::ItemAvailability.stock_report_for_android(params[:stock]["branch"], params[:stock]["brand"])
        
        if params[:page]
          @stocks = Kaminari.paginate_array(@stocks).page(params[:page]).per(10)  
          total_pages = (@stocks.count / 10).ceil
          current_page = params[:page]
        else
          @stocks = Kaminari.paginate_array(@stocks).page(1).per(10)  
          current_page = 1
        end
        
        render json: {status: "SUCCESS", message: 'Loaded Stock', data_stocks: @stocks}
        return 
      end
      
    end
  end
end