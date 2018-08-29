

return {
  id = "HealerIvern",
  name = "Healer Ivern",
  riot = true,
  flag = {
    text = "H E A L E R",
    color = {
    text = 0xffeeeeee,
    background1 = 0xffeeeeee,
    background2 = 0xFF5F021F,
       }
  },
  load = function()
    return player.charName == "Ivern"
  end
}
