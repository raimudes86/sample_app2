module UsersHelper
    #引数で与えられたユーザーのFravatar画像を返す
    def gravatar_for(user, size: 200)
        gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
        gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
        image_tag(gravatar_url, alt: user.name, class: "gravatar")
    end
end
