module UsersHelper
  def gravatar_for user
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag gravatar_url, alt: user.name, class: "gravatar"
  end

  def gender_options_for_select
    [
      [t("users._form.gender_female"), :female],
      [t("users._form.gender_male"), :male],
      [t("users._form.gender_other"), :other]
    ]
  end
end
