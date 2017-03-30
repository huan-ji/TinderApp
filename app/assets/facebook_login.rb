require 'rest-client'
require 'capybara'
require 'capybara/dsl'

Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.default_max_wait_time = 30

module FacebookLogin
  class Auth
    include Capybara::DSL

    FACEBOOK_AUTHENTICATION_TOKEN_URL =
      "https://www.facebook.com/dialog/oauth?" \
      "client_id=464891386855067&" \
      "redirect_uri=fb464891386855067://authorize/&" \
      "&scope=user_birthday,user_photos,user_education_history,email,user_relationship_details," \
      "user_friends,user_work_history,user_likes&" \
      "response_type=token"

    def get_credentials(facebook_email, facebook_password)
      visit FACEBOOK_AUTHENTICATION_TOKEN_URL
      fill_in('email', with: facebook_email)
      fill_in('pass', with: facebook_password)
      click_button('Log In')

      fb_dtsg = find('input[name=fb_dtsg]', visible: false).value

      cookies = page.driver.browser.manage.all_cookies.map { |cookie| "#{cookie[:name]}=#{cookie[:value]};" }.join(' ')
      token_response = RestClient.post(
        'https://www.facebook.com/dialog/oauth/confirm',
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
          ref: 'Default'
        },
        {
          cookie: cookies
        }
      )

      fb_auth_token = token_response.body.match(/access_token=([\w_]+)&/)[1]
      id_response = RestClient.get("https://graph.facebook.com/me?access_token=#{fb_auth_token}")
      fb_user_id = JSON.parse(id_response.body)["id"]
      page.driver.quit

      return {
        fb_auth_token: fb_auth_token,
        fb_user_id: fb_user_id,
        success: true
      }
    end
  end
end
