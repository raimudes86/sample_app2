class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence:   true, length: { maximum: 255 },
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: {minimum: 8}, allow_nil: true

  class << self
    #渡された文字列のハッシュ値を返す
    #ActiveModel::SecurePasswordは本番環境以外だと低くされるので、min_costがtrueになることがある
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    #ランダムなトークンを渡す
    #クラスに属するメソッドであることを明示するためにUser.とつける
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  #永続的セッションのためにユーザーをデータベースに記憶する
  #ランダムな文字列を生成して、それを暗号化してデータベースに保存！
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  #渡されたトークンがダイジェストと一致したらtrueを返す
  #パスワードを認証するのはauthenticateなので似てるけど大丈夫
  #そのユーザーの持つリメンバーダイジェストがnilならfalseを返さないとエラーを吐いてしまう
  def token_authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  #sessionハイジャック防止のために、セッショントークンを返す
  #この記憶ダイジェストを再利用しているのは単に利便性のため
  #(remember_digestが存在すればそれを返し、しなければ生成して、生成ほやほやのやつを返す)
  def session_token
    remember_digest || remember
  end

  #ユーザーのログイン情報を破棄する→remember_digestを破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
end
  