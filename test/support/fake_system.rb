Magic = Measured.build do
  unit :magic_missile, aliases: [:magic_missiles]
  unit :fireball, value: "2/3 magic_missile", aliases: [:fire, :fireballs]
  unit :ice, value: "2 magic_missile"
  unit :arcane, value: "10 magic_missile"
  unit :ultima, value: "10 arcane"
end

CaseSensitiveMagic = Measured.build(case_sensitive: true) do
  unit :magic_missile, aliases: [:magic_missiles]
  unit :fireball, value: "2/3 magic_missile", aliases: [:fire, :fireballs]
  unit :ice, value: "2 magic_missile"
  unit :arcane, value: "10 magic_missile"
  unit :ultima, value: "10 arcane"
end

OtherFakeSystem = Measured.build do
  unit :other_fake_base
  unit :other_fake1, value: "2 other_fake_base"
end
