

return {
  id = "HealerKennen",
  name = "Kennen",
  riot = true,
  flag = {
    text = "H E A L E R",
    color = {
      text = 0xffeeeeee,
      background1 = 0xFFaaffff,
      background2 = 0xFF000000    }
  },
  load = function()
    return player.charName == "Kennen"
  end
}
