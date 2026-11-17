local persist = require("chroma.persist")

persist.clear()
assert(persist.load() == nil, "state should start empty")

assert(persist.save("tokyonight"), "save failed")
assert(persist.load() == "tokyonight", "load returned the wrong theme")

persist.clear()
assert(persist.load() == nil, "clear did not remove the saved theme")

print("ok: persist save/load/clear")
