# app/controllers/api/v1/phrases_controller.rb
module Api
  module V1
    class PhrasesController < ApplicationController
      # フレーズを見つけるためのbefore_action
      before_action :set_phrase, only: [:show]

      # GET /api/v1/phrases/:id
      def show
        render json: @phrase
      end

      private

      # IDに基づいてフレーズを見つけるメソッド
      def set_phrase
        @phrase = Phrase.find(params[:id])
      end
    end
  end
end
