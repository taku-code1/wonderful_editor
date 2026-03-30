# 1. 何よりも先に、Ruby標準のLoggerを強制ロードする
require "logger"

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# 2. RailsのActiveSupport Loggerを強制ロードする
require "active_support/logger"

# 3. エラーの原因となっている箇所をここで定義してしまう
module ActiveSupport
  module LoggerThreadSafeLevel
    Logger = ::Logger
  end
end

begin
  require "bootsnap/setup"
rescue LoadError
end
