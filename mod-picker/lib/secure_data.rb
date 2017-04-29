class SecureData
  MAGIC_1 = 1.6
  MAGIC_2 = 1.614
  MAGIC_3 = 7
  MAGIC_4 = 1.34
  MIN_OFFSET = 8
  MIN_PAD = 5
  MAX_PAD = 49

  def self.get_key(user)
    base = user.username + user.role + user.reputation.overall.to_s
    (Digest::SHA256.digest base).bytes.to_a
  end

  def self.offset(i, d)
    (((i + MIN_OFFSET) * MAGIC_1 + d) / MAGIC_2).to_i
  end

  def self.crypt_string(str, key, dec)
    result = ""
    kl = key.length
    str.length.times do |i|
      kv = (key[i % kl] + self.offset(i, dec)) % 255
      result << "%02X" % (kv ^ (str[i] || 0).ord)
    end
    result
  end

  def self.pad_string(str, user)
    amt = MIN_PAD + (MAGIC_3 * user.id**MAGIC_4) % (MAX_PAD - MIN_PAD)
    SecureRandom.hex(amt.to_i).upcase + str
  end

  def self.full(user, str)
    self.pad_string(self.crypt_string(str, self.get_key(user), user.id), user)
  end
end