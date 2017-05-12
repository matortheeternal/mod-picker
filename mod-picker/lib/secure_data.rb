require 'narray'

class SecureData
  MAGIC = "ag6xfJ7uqg"

  def self.xor(str, key)
    if key.empty?
      str
    else
      if key.length < str.length
        div, mod = str.length.divmod(key.length)
        key = key * div + key[0, mod]
      end

      a1 = NArray.to_na(str, "byte")
      a2 = NArray.to_na(key, "byte")

      (a1 ^ a2).to_s
    end
  end

  def self.get_key(user)
    base = "#{user.role}#{MAGIC}#{user.id}#{user.username}"
    Digest::SHA256.digest base
  end

  def self.full(user, str)
    self.xor(str, self.get_key(user))
  end
end