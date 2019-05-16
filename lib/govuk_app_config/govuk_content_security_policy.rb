module GovukContentSecurityPolicy
  # Generate a Content Security Policy (CSP) directive.
  #
  # See https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP for more CSP info.
  #
  # The resulting policy should be checked with:
  #
  # - https://csp-evaluator.withgoogle.com
  # - https://cspvalidator.org
  GOVUK_DOMAINS = %w(*.publishing.service.gov.uk).freeze

  GOOGLE_ANALYTICS_DOMAINS = %w(www.google-analytics.com ssl.google-analytics.com stats.g.doubleclick.net).freeze

  def self.apply_base_policy(policy)
    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/default-src
    policy.default_src :https, :self, *GOVUK_DOMAINS

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/img-src
    policy.img_src :self,
                   :data,  # Base64 encoded images
                   *GOVUK_DOMAINS,
                   *GOOGLE_ANALYTICS_DOMAINS, # Analytics use tracking pixels
                   # Some images still links to an old domain we used to use
                   "assets.digital.cabinet-office.gov.uk"

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/script-src
    policy.script_src :self,
                      *GOVUK_DOMAINS,
                      *GOOGLE_ANALYTICS_DOMAINS,
                      # Allow JSONP call to Verify to check whether the user is logged in
                      "www.signin.service.gov.uk",
                      # Allow YouTube Embeds (Govspeak turns YouTube links into embeds)
                      "*.ytimg.com",
                      "www.youtube.com"

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/style-src
    policy.style_src :self,
                     *GOVUK_DOMAINS

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/connect-src
    policy.connect_src :self,
                       *GOVUK_DOMAINS,
                       *GOOGLE_ANALYTICS_DOMAINS,
                       # Allow connecting to web chat from HMRC contact pages
                      "www.tax.service.gov.uk",
                      # Allow connecting to Verify to check whether the user is logged in
                      "www.signin.service.gov.uk"

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/object-src
    policy.object_src :none

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/object-src
    policy.frame_src "www.youtube.com"

    # Generate a nonce that can be used for inline scripts
    Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

    if Rails.env.production?
      # In test and development, use CSP for real to find issues. In production we only
      # report violations to Sentry (https://sentry.io/govuk/govuk-frontend-csp) via an
      # AWS Lambda function that filters out junk reports.
      policy.report_uri "https://jhpno0hk6b.execute-api.eu-west-2.amazonaws.com/production"
      Rails.application.config.content_security_policy_report_only = true
    end
  end

  def self.configure
    Rails.application.config.content_security_policy do |policy|
      apply_base_policy(policy)
    end
  end
end
