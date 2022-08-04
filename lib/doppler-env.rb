require "net/http"
require "json"
require "open3"

module DopplerEnv
  DOPPLER_TOKEN = ENV["DOPPLER_TOKEN"]
  DOPPLER_PROJECT = ENV["DOPPLER_PROJECT"]
  DOPPLER_CONFIG = ENV["DOPPLER_CONFIG"]
  DOPPLER_URL = URI("https://api.doppler.com/v3/configs/config/secrets/download")

  # get path to Ruby binary being used for debug purposes
  RUBY = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name']).sub(/.*\s.*/m, '"\&"')

  module_function

  def log(message)
    puts "[doppler-env]: #{message}"
  end

  def log_debug
    log "[DEBUG] Token: #{DOPPLER_TOKEN && DOPPLER_TOKEN.to_s.split(".")[0...-1].push("*****").join(".").inspect || DOPPLER_TOKEN.inspect}"
    log "[DEBUG] Project: #{DOPPLER_PROJECT.inspect}"
    log "[DEBUG] Config: #{DOPPLER_CONFIG.inspect}"
    log "[DEBUG] Ruby path: #{RUBY}"
    log "[DEBUG] Working directory: #{Dir.getwd}"
  end

  # loads secrets into ENV so long as the variable doesn't already exist
  def load_secrets(secrets)
    secrets.each do |k,v|
      ENV[k] ||= v
    end
    log "Secrets loaded successfully:"
    log "  project=#{ENV["DOPPLER_PROJECT"]} config=#{ENV["DOPPLER_CONFIG"]} environment=#{ENV["DOPPLER_ENVIRONMENT"]}"
  end

  # loads secrets into ENV, overwriting any variables that already exist
  def load_secrets!(secrets)
    secrets.each do |k,v|
      ENV[k] = v
    end
    log "Secrets loaded successfully:"
    log "  project=#{ENV["DOPPLER_PROJECT"]} config=#{ENV["DOPPLER_CONFIG"]} environment=#{ENV["DOPPLER_ENVIRONMENT"]}"
  end

  # this method expects `doppler setup` to have already been run
  def fetch_secrets_cli
    command = "doppler secrets download --no-file".split(" ")

    begin
      stdout, stderr, status = Open3.capture3(*command)
    rescue Errno::ENOENT
      log "No secrets loaded. The Doppler CLI is not installed. See https://docs.doppler.com/docs/install-cli."
      log_debug
      return
    end

    if status.success?
      JSON.parse(stdout)
    else
      log "Error: No secrets loaded. CLI failed to load secrets. Please make sure `doppler setup` has been run."
      log_debug
      return
    end
  end

  # if using a service token, the project and config are inferred. if using a
  # personal or CLI token you need to supply a project and config.
  def fetch_secrets_api
    unless DOPPLER_PROJECT && DOPPLER_CONFIG || DOPPLER_TOKEN.start_with?("dp.st")
      log "Error: No secrets loaded. DOPPLER_PROJECT and DOPPLER_CONFIG environment variables must be set if using a CLI or Personal Token."
      log_debug
      return
    end
    params = { project: DOPPLER_PROJECT, config: DOPPLER_CONFIG, format: "json" }
    DOPPLER_URL.query = URI.encode_www_form(params)

    req = Net::HTTP::Get.new(DOPPLER_URL)
    req.basic_auth DOPPLER_TOKEN, ""

    res = Net::HTTP.start(DOPPLER_URL.hostname, DOPPLER_URL.port, use_ssl: true) do |http|
      http.request(req)
    end

    case res
    when Net::HTTPSuccess
      return JSON.parse(res.body)
    when Net::HTTPUnauthorized
      log "Unauthorized: No secrets loaded. Please make sure you're using a valid Doppler token."
      log_debug
    else
      log res.inspect
      log "Error: No secrets loaded. A failure occurred while attempting to load secrets."
      log_debug
    end
  end

  def load(override = false)
    # if `DOPPLER_TOKEN` is set, we use the API. if that isn't set, we use the
    # CLI and expect `doppler setup` to have been run already.
    if DOPPLER_TOKEN
      log "DOPPLER_TOKEN environment variable set. Fetching secrets from Doppler API."
      secrets = fetch_secrets_api
    else
      log "Fetching secrets using Doppler CLI."
      secrets = fetch_secrets_cli
    end
  
    if secrets
      # if `override` is true, we will override any existing env
      # variables that existed with new ones coming in from Doppler. otherwise,
      # pre-existing variables are left untouched.
      if override
        load_secrets!(secrets)
      else
        load_secrets(secrets)
      end
    end
  end

  def load!
    load(true)
  end
end
