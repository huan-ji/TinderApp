require 'rest-client'
require 'capybara'
require 'capybara/dsl'

Capybara.run_server = false
Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, headers: { 'HTTP_USER_AGENT' => 'Mozilla/5.0 (Linux; U; en-gb; KFTHWI Build/JDQ39) AppleWebKit/535.19 (KHTML, like Gecko) Silk/3.16 Safari/535.19' })
end
Capybara.current_driver = :selenium
Capybara.app_host = 'https://www.gotinder.com'

module FacebookLogin
  class Auth
    include Capybara::DSL
    FACEBOOK_AUTHENTICATION_TOKEN_URL =
    "https://www.facebook.com/v2.0/dialog/oauth?" \
    "client_id=464891386855067&" \
    "redirect_uri=fb464891386855067://authorize/&" \
    "&scope=user_birthday,user_photos,user_education_history,email,user_relationship_details,user_friends,user_work_history,user_likes&" \
    "response_type=token"

    def get_credentials(facebook_email, facebook_password)
      visit FACEBOOK_AUTHENTICATION_TOKEN_URL
      fill_in('email', with: facebook_email)
      fill_in('pass', with: facebook_password)
      click_button('Log In')

      fb_dtsg = find('input[name=fb_dtsg]', visible: false).value
      
      cookie = page.driver.browser.manage.all_cookies.map { |cookie| "#{cookie[:name]}=#{cookie[:value]};"}.join(' ')
      token_response = RestClient.post(
        'https://www.facebook.com/v2.3/dialog/oauth/confirm',
        {
          app_id: '464891386855067',
          fb_dtsg: fb_dtsg,
          ttstamp: '2658170904850115701205011500',
          redirect_uri: 'fbconnect://success',
          return_format: 'access_token',
          from_post: 1,
          display: 'popup',
          gdp_version: 4,
          sheet_name: 'initial',
          __CONFIRM__: 1,
          sso_device: '',
          ref: 'Default',
        },
        headers = {
          cookie: cookie
        }
      )

      facebook_authentication_token = token_response.body.match(/access_token=([\w_]+)&/)[1]
      id_response = RestClient.get("https://graph.facebook.com/me?access_token=#{facebook_authentication_token}")
      facebook_user_id = JSON.parse(id_response.body)["id"]

      return facebook_authentication_token, facebook_user_id
    end
  end
end
