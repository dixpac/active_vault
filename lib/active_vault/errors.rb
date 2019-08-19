# frozen_string_literal: true

module ActiveVault
  # Generic base class for all Active Vault exceptions.
  class Error < StandardError; end

  # Raised when Cipher is unable to decrypt cipher text.
  class DecryptionError < Error; end
end
