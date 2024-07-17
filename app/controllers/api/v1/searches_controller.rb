require_dependency Rails.root.join('app/services/scraping_service')

class Api::V1::SearchesController < ApplicationController
    def show
      keyword = params[:japanese]
      results = ScrapingService.scrape_data(keyword)
      render json: results
    end
  end