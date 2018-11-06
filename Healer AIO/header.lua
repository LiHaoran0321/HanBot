local HealerAIOchampions = {
  Yorick = true,
  Sona = true,
  Ivern = true,
  Kayle = true,
  Karthus = true,
  Kennen = true,
  Kindred = true,
  Lux = true,
  Malzahar = true,
  Trundle = true,
  Illaoi = true,
  Ekko = true
}

return {
  id = "HealerAIO" .. player.charName,
  name = "Healer AIO - " .. player.charName,
  riot = true,
  flag = {
    text = "H E A L E R   A I O",
    color = {
      text = 0xffeeeeee,
      background1 = 0xffeeeeee,
      background2 = 0xFF21214E
    }
  },
  load = function()
    return HealerAIOchampions[player.charName]
  end
}
