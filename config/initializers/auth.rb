
credentials = YAML.load_file(Rails.root.join('config/auth.yml').to_s)[Rails.env].symbolize_keys

Rails.application.auth = credentials
