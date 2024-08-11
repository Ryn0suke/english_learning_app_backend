module Api
  module V1
    class PhrasesController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :correct_user, only: [:destroy, :update]

      def show
        @user = User.find(params[:id])
        @phrases = @user.phrases.search(params).page(params[:page]).per(10)
        
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
        render json: { total_pages: @phrases.total_pages, phrases: phrases_with_tags }
      end

      # POST /api/v1/phrases
      # 新しいフレーズを作成する
      def create
        @phrase = current_api_v1_user.phrases.build(phrase_params)
        
        tag_names = params.require(:tags).map { |tag| tag.permit(:name)[:name] }

        if (@phrase.tags.pluck(:name) + tag_names).length > 20
          render json: { message: 'タグは20個までしか登録できません' }, status: :unprocessable_entity
          return
        end

        ActiveRecord::Base.transaction do
          if @phrase.save
            # checkテーブルに初期値を登録
            Check.create!(user: current_api_v1_user, phrase: @phrase, state1: false, state2: false, state3: false)
            
            add_tags_to_phrase(@phrase, tag_names)
            render json: @phrase, status: :created
          else
            render json: { errors: @phrase.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end

      # PUT /api/v1/phrases/:id
      # あるフレーズIDのフレーズを更新(ただし、user_idが一致しているときのみ)
      def update
        @phrase = current_api_v1_user.phrases.find_by(id: params[:id])
      
        if @phrase.nil?
          render json: { errors: ['フレーズが見つかりません'] }, status: :unprocessable_entity
          return
        end

        current_tags = @phrase.tags.pluck(:name)
        new_tags = params.require(:tags).map { |tag| tag.permit(:name)[:name] }
        delete_tags = current_tags - new_tags
        add_tags = new_tags - current_tags

        if (current_tags - new_tags + add_tags).length > 20
          render json: { message: 'タグは20個までしか登録できません' }, status: :unprocessable_entity
          return
        end
      
        ActiveRecord::Base.transaction do
          if @phrase.update(phrase_params)
            #チェック状態の更新
            @phrase.check.update!(check_params)

            remove_tags_from_phrase(@phrase, delete_tags)
            add_tags_to_phrase(@phrase, add_tags)
      
            render json: @phrase, status: :ok
          else
            render json: { errors: @phrase.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end

      # DELETE /api/v1/phrases/:id
      # あるフレーズIDのフレーズを削除(ただし、user_idが一致しているときのみ)
      def destroy
        @phrase = current_api_v1_user.phrases.find_by(id: params[:id])
        
        if @phrase
          ActiveRecord::Base.transaction do
            # @phraseに紐づいているtagを調べる
            linked_tags = @phrase.tags
            
            linked_tags.each do |linked_tag|
              # 現在のユーザーに関連付けられたフレーズでそのタグが他に使われているかを確認
              if linked_tag.phrases.where(user_id: current_api_v1_user.id).count == 1
                # 他のフレーズで使われていない場合、タグユーザーリレーションを削除
                TagUserRelation.where(user_id: current_api_v1_user.id, tag_id: linked_tag.id).destroy_all
              end
            end
            
            # フレーズとそのチェックを削除
            @phrase.destroy
            
            render json: { message: 'フレーズが削除されました' }, status: :ok
          end
        else
          render json: { message: 'フレーズが見つかりません' }, status: :not_found
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end

      private

      def correct_user
        @phrase = current_api_v1_user.phrases.find_by(id: params[:id])
        render json: { message: '許可されていません' }, status: :forbidden if @phrase.nil?
      end

      def phrase_params
        params.require(:phrase).permit(:user_id, :japanese, :english)
      end

      def check_params
        params.permit(:state1, :state2, :state3)
      end
      
      def add_tags_to_phrase(phrase, tags)
        tags.each do |tag_name|
          tag = Tag.find_or_create_by!(name: tag_name)
          phrase.tags << tag unless phrase.tags.include?(tag)
          tag_user_relation = TagUserRelation.find_or_initialize_by(user: current_api_v1_user, tag: tag)
          tag_user_relation.save! unless tag_user_relation.persisted?
        end
      end

      def remove_tags_from_phrase(phrase, tags)
        tags.each do |tag_name|
          tag = Tag.find_by(name: tag_name)
          if tag
            phrase.tags.delete(tag)
            if tag.phrases.where(user_id: current_api_v1_user.id).empty?
              TagUserRelation.where(user: current_api_v1_user, tag: tag).destroy_all
            end
          end
        end
      end
      
    end
  end
end
