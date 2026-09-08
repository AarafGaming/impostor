import std/[random, strutils]

proc isSimpleWord(word: string): bool =
  if word.len == 0:
    return false

  for c in word:
    if c < 'a' or c > 'z':
      return false

  return true

let data = readFile("words.txt")

var words: seq[string] = @[]

for line in data.splitLines():
  let word = line.strip().toLowerAscii()
  if isSimpleWord(word):
    words.add(word)

randomize()

if words.len == 0:
  echo "No valid words found."
  quit(1)

let secretWord = sample(words)

var names: seq[string] = @[]
echo "Leave blank once you are done adding players."
while true:
  echo "Add name: "
  let playerName = readLine(stdin)
  if playerName == "":
    break
  names.add(playerName)

if names.len == 0:
  echo "No players entered."
  quit(1)

let impostor = names[rand(names.len - 1)]

for i in 0 ..< names.len:
  stdout.write("\x1b[H\x1b[2J")
  echo "Hand to ", names[i], " and don't look until that player is done looking at the word."
  echo "If you are the player that is supposed to see, press enter"
  discard readLine(stdin)
  if impostor == names[i]:
    echo "You are the impostor."
  else:
    echo "Word: ", secretWord
  echo "After seeing, press enter."
  discard readLine(stdin)

echo "Press enter to reveal impostor"
discard readLine(stdin)
echo "Impostor: ", impostor

