module Api
  module V1
    class PhrasesController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :phrase_params, only:[:create]
      before_action :correct_user, only: [:destroy, :update]

      # GET /api/v1/phrases/:id
      #あるユーザーの登録しているフレーズを全て返す

      # SELECT
      #   tags.name
      # FROM
      #   tags
      # INNER JOIN
      #   phrase_tag_relations
      # ON
      #   tags.id = phrase_tag_relations.tag_id
      # INNER JOIN
      #   phrases
      # ON
      #   phrase_tag_relations.phrase_id = phrases.id
      # WHERE
      #   phrases.id = tags.id

      def show
        @user = User.find(params[:id])
        @phrases = @user.phrases.page(params[:page]).per(20)
        
        phrases_with_tags = @phrases.map do |phrase|
          {
            # phrase: phrase,
            # tags: phrase.tags
            id: phrase.id,
            japanese: phrase.japanese,
            english: phrase.english,
            tags: phrase.tags,
          }
        end

        # render json: { total_pages: @phrases.total_pages, phrases: @phrases }
        render json: { total_pages: @phrases.total_pages, phrases: phrases_with_tags }
      end

      # POST /api/v1/phrases
      # 新しいフレーズを作成する
      def create
        @phrase = current_api_v1_user.phrases.build(phrase_params)
        puts params[:phrase]
        
        tag_params = params.require(:tags).map { |tag| tag.permit(:name).to_h }
        tag_names = tag_params.map { |tag| tag[:name] }
        
        if tag_names.length + current_api_v1_user.tag_user_relations.count > 20
          render json: { message: 'タグは20個までしか登録できません' }, status: :unprocessable_entity
          return
        else
          if @phrase.save
            tag_names.each do |tag_name|
              puts tag_name
              tag = Tag.find_or_create_by(name: tag_name) # タグを見つけるか、作成
              @phrase.tags << tag # フレーズにタグを追加
              tag_user = TagUserRelation.new(user: current_api_v1_user, tag: tag)
              unless tag_user.save
                @phrase.destroy
                render json: { errors: tag_user.errors.full_messages }, status: :unprocessable_entity
                return
              end
            end
            render json: @phrase, status: :created
          else
            render json: { errors: @phrase.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end
      
      

      # PUT /api/v1/phrases/:id
      # あるフレーズIDのフレーズを更新(ただし、user_idが一致しているときのみ)
      def update
        @phrase = current_api_v1_user.phrases.find_by(id: params[:id])
        if @phrase && @phrase.update(phrase_params)
          render json: @phrase, status: :ok
        else
          render json: { errors: @phrase ? @phrase.errors.full_messages : ['フレーズが見つかりません'] }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/phrases/:id
      # あるフレーズIDのフレーズを削除(ただし、user_idが一致しているときのみ)
      def destroy
        @phrase = current_api_v1_user.phrases.find_by(id: params[:id])
        if @phrase
          @phrase.destroy
          render json: { message: 'フレーズが削除されました' }, status: :ok
        else
          render json: { message: 'フレーズが見つかりません' }, status: :not_found
        end
      end

      private

      def correct_user
        @phrase = current_api_v1_user.phrases.find_by(id: params[:id])
        render json: { message: '許可されていません' }, status: :forbidden if @phrase.nil?
      end

      def phrase_params
        params.require(:phrase).permit(:user_id, :japanese, :english)
      end
      
    end
  end
end
