require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  shared_examples_for 'authenticate' do
    subject { response }
    before  { session[:user_id] = nil }

    context 'ログインしていないとき' do
      it 'トップページにリダイレクトすること' do
        expect(response).to redirect_to root_path
      end
    end
  end

  before do
    @user = create(:user)
    session[:user_id] = @user.id
  end

  describe 'GET /events/new' do
    context 'ログインしているとき' do
      before do
        get :new
      end

      it 'ステータスコードが200であること' do
        expect(response.status).to eq 200
      end

      it 'ビューとして new.html.erb が呼ばれること' do
        expect(response).to render_template 'new'
      end

      it '@event にセッションのユーザIDと紐付く空イベントが格納されていること' do
        expect(assigns(:event)).to be_a_new(Event)
        expect(assigns(:event).owner_id).to eq @user.id
      end
    end

    it_behaves_like 'authenticate' do
      let(:response) { get :new }
    end
  end

  describe 'POST /events/' do
    context 'ログインしているとき' do
      context '登録成功するとき' do
        context 'フォームに全てのデータが入力されているとき' do
          before do
            @params = { event: attributes_for(:event) }
            post :create, @params
          end

          it '/event/:作成したイベントID にリダイレクトされること' do
            expect(response).to redirect_to assigns(:event)
          end

          it 'フォーム送信されたデータと、DBに登録されたデータが一致すること' do
            columns = @params[:event].keys
            expect(assigns(:event).attributes.symbolize_keys.slice(*columns)).to eq @params[:event]
          end

          it 'flash[:notice] に「作成しました。」という文字列が格納されていること' do
            expect(flash[:notice]).to eq '作成しました。'
          end
        end
      end

      context '登録失敗するとき' do
        context 'フォームに入力されたデータが空のとき' do
          before do
            @params = { event: attributes_for(:event, :with_blank) }
            post :create, @params
          end

          it 'ステータスコードが200であること' do
            expect(response.status).to eq 200
          end

          it 'ビューとして new.html.erb が呼ばれること' do
            expect(response).to render_template(:new)
          end

          it '@eventにエラー情報が格納されていること' do
            expect(assigns(:event).errors.any?).to be_truthy
          end
        end
      end
    end

    it_behaves_like 'authenticate' do
      let(:response) { post :create }
    end
  end
end
