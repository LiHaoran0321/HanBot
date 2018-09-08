

return {
  id = "HealerKindred",
  name = "Healer Kindred",
  riot = true,
  flag = {
    text = "H E A L E R",
    color = {
      text = 0xFFFFF700,
      background1 = 0xFFFFF700,
      background2 = 0xFF5F021F    }
  },
  load = function()
    return player.charName == "Kindred"
  end
}
