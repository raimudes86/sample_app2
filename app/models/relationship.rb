class Relationship < ApplicationRecord
    belongs_to :follower, class_name: "User"
    belongs_to :followed, class_name: "User"
    #rails5以降は書かなくてもいいが、念の為省略しない
    validates :follower_id, presence: true
    validates :followed_id, presence: true
end
