

return {
  id = "HealerSona",
  name = "Healer Sona",
  riot = true,
  flag = {
    text = "H E A L E R",
    color = {
    text = 0xFFFFF700,
    background1 = 0xffeeeeee,
    background2 = 0xFF21214E,
       }
  },
  load = function()
    return player.charName == "Sona"
  end
}
