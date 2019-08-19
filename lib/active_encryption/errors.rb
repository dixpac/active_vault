# frozen_string_literal: true

module ActiveEncryption
  # Generic base class for all Active Encryption exceptions.
  class Error < StandardError; end

  # Raised when Cipher is unable to decrypt cipher text.
  class DecryptionError < Error; end
end
