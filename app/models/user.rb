class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
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
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
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

  #アカウントを有効にする
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  #有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  #パスワードの再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:User.digest(reset_token), reset_sent_at: Time.zone.now)
  end
  
  #パスワード再設定のメールを送信する
  #password_reset(self)はMailerにオブジェクトを渡してそれを持ちいてメールの内容を設定すること
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  #パスワードの再設定の有効期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  
  def feed
    Micropost.where("user_id = ?", id)
  end

  private
    #メールアドレスをすべて小文字にする
    def downcase_email
      email.downcase!
    end

    #有効かトークンとダイジェストを作成および代入
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
  