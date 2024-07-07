module Api
    module V1
      class QuestionsController < ApplicationController
        before_action :authenticate_api_v1_user!
  
        def show
          @user = User.find(params[:id])

          page = params[:option][:page].to_i
          num_of_questions = params[:option][:numOfQuestions].to_i

          @phrases = @user.phrases.search_for_question(params).page(page).per(num_of_questions)#params[:numOfQuestions].to_i)

          phrases_with_tags = @phrases.map do |phrase|
            state = phrase.check
            state1, state2, state3 = state[:state1], state[:state2], state[:state3]
            {
              id: phrase.id,
              japanese: phrase.japanese,
              english: phrase.english,
              tags: phrase.tags,
              state1: state1,
              state2: state2,
              state3: state3,
            }
          end
  
          render json: { phrases: phrases_with_tags }
        end
  
        private
  
        def correct_user
          @phrase = current_api_v1_user.phrases.find_by(id: params[:id])
          render json: { message: '許可されていません' }, status: :forbidden if @phrase.nil?
        end
  
        def phrase_params
          params.require(:option).permit(:tags, :state1, :state2, :state3, :numOfQuestions, :page, :isJapaneseToEnglish)
        end
      end
    end
  end
  