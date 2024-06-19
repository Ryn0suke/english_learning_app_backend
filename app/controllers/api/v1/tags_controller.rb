module Api
    module V1
        class TagsController < ApplicationController
            before_action :authenticate_api_v1_user!
            before_action :tag_params, :correct_user
            def index
                @tags = current_api_v1_user.tags
              
                use_tags = @tags.map do |tag|
                  {
                    id: tag.id,
                    name: tag.name
                  }
                end
              
                render json: { tags: use_tags }
                return
            end
            

            private
            def correct_user
              puts params
              # params[:id]からユーザーIDを取得
              user_id = params[:id]
            
              # 現在のユーザーが持っているtag_user_relationsの中から、指定されたユーザーIDに関連するものを取得
              tag_user_relation = current_api_v1_user.tag_user_relations.find_by(user_id: user_id)
            
              # 関連するタグが存在するかどうかを確認
              if tag_user_relation
                @tag = current_api_v1_user.tags.find_by(id: tag_user_relation.tag_id)
              else
                @tag = nil
              end
            
              # タグが存在しない場合、許可されていないメッセージを返す
              render json: { message: '許可されていません' }, status: :forbidden if @tag.nil?
            end
              
      
            def tag_params
              params.permit(:id)
            end
        end
    end
end
