class Api::V1::SessionsController < Api::V1::ApplicationController

  skip_before_action :authenticate_user_by_token, only: [:create]

  def create
    return unless clean_http_basic_params
    @user = User.find_by(email: login_params[:email])

    if @user && @user.authenticate(login_params[:password])
      @user.session.create_token

      @session = @user.session
      render :show, status: :created
    else
      render json: {
        "errors": ["invalid email or password"]
      }.to_json, status: :unauthorized
    end
  end

  def destroy
    session_to_destroy = Session.find_by(id: params[:id])
    if session_to_destroy.nil?
      render json: {
        "errors": ["session not found"]
      }.to_json, status: :unprocessable_entity
    elsif session_to_destroy.id == @session.id
      session_to_destroy.destroy_token
      head :no_content
    else
      render json: {
        "errors": ["cannot logout another user"]
      }.to_json, status: :forbidden
    end
  end

  def show
    session = Session.find_by(id: params[:id])
    if session
      if session == @session
        render :show, status: :ok
      else
        render json: {
          "errors": ["cannot fetch another user session"]
        }.to_json, status: :forbidden
      end
    else
      render json: {
        "errors": ['session not found']
      }.to_json, status: :unprocessable_entity
    end
  end

  private

    def login_params
      params.require(:user).permit(:email, :password)
    end
end
