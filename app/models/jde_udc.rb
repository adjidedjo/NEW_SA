class JdeUdc < ActiveRecord::Base
  establish_connection :jdeoracle
  self.table_name = "prodctl.f0005" #dr

  def self.jenis_udc(code)
    jenis = where("drsy = ? and drrt = ? and drky like ?", "55", "JN", "%#{code}")
    jenis.empty? ? "" : jenis.first.drdl01.strip
  end

  def self.artikel_udc(code)
    artikel = where("drsy = ? and drrt = ? and drky like ?", "55", "AT", "%#{code}")
    artikel.empty? ? "" : artikel.first.drdl01.strip
  end

  def self.kain_udc(code)
    kain = where("drsy = ? and drrt = ? and drky like ?", "55", "KA", "%#{code}")
    kain.empty? ? "" : kain.first.drdl01.strip
  end

  def self.group_item_udc(code)
    group = where("drsy = ? and drrt = ? and drky like ?", "41", "S3", "%#{code}%")
    group.empty? ? "" : group.first.drdl01.strip
  end
end
