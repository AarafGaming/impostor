import std/[random, strutils, sequtils]

proc isSimpleWord(word: string): bool =
  if word.len == 0:
    return false

  for c in word:
    if c < 'a' or c > 'z':
      return false

  return true

let wordsdata = readFile("words.txt")
let hintsdata = readFile("hints.txt")
var words: seq[string] = @[]
var hints: seq[string] = @[]

for line in wordsdata.splitLines():
  let word = line.strip().toLowerAscii()
  if isSimpleWord(word):
    words.add(word)

for line in hintsdata.splitLines():
  let hint = line.strip().toLowerAscii()
  if isSimpleWord(hint):
    hints.add(hint)

randomize()

if words.len == 0:
  echo "No valid words found."
  quit(1)

let secretWord = sample(words)
let wordHint = hints[words.find(secretWord) - 1]
var names: seq[string] = @[]
var impostors: seq[string] = @[]
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

var nonimpostors = names
var inthegame = names
stdout.write("Enter amount of impostors: ")
var impostor_amount: int = 0
try:
    impostor_amount = parseInt(readLine(stdin))
except ValueError:
    echo "\nInvalid impostor amount, defaulting to 1."
    impostor_amount = 1
echo ""
var impostorsKnoweachOther = false
if impostor_amount > 1:
    stdout.write("Will impostors know each other? (y/n)")
    var input = readLine(stdin)
    if input == "y":
        impostorsKnoweachOther = true
    else:
        impostorsKnoweachOther = false

var showHint = false
if impostor_amount > 1:
    stdout.write("Will hints be shown? (y/n)")
    var input = readLine(stdin)
    if input == "y":
        showHint = true
    else:
        showHint = false

else:
    impostorsKnoweachOther = false
for i in 1 .. impostor_amount:
    var impostor = rand(0..(nonimpostors.len - 1))
    impostors.add(nonimpostors[impostor])
    nonimpostors.delete(impostor)
for i in 0 ..< names.len:
  stdout.write("\x1b[H\x1b[2J")
  echo ""
  echo "Hand to ", names[i], " and don't look until that player is done looking at the word."
  echo "If you are the player that is supposed to see, press enter"
  discard readLine(stdin)
  if names[i] in impostors:
    echo "You are the impostor."
    if impostorsKnoweachOther:
        echo "Impostors: ", impostors.join(", ")
  else:
    echo "Word: ", secretWord
  if showHint:
      echo wordHint
  echo "After seeing, press enter."
  discard readLine(stdin)
var votes: seq[int]
while true:
  echo "Press enter to start vote"
  setLen(votes, 0)
  for i in countup(0, inthegame.len - 1):
      votes.add(0)
  for i in countup(0, inthegame.len - 1):
      echo "Enter " & inthegame[i] & "'s vote"
      for j in countup(0, inthegame.len - 1):
          echo j, ": " & inthegame[j]
      votes[parseInt(readLine(stdin))] += 1
  if inthegame[foldl(votes, if a > b: a else: b)] in impostors:
      echo "Impostor got voted out."
      impostors.del(impostors.find(inthegame[foldl(votes, if a > b: a else: b)]))
      inthegame.del(foldl(votes, if a > b: a else: b))
  else:
      echo "Impostors win."
      discard readLine(stdin)
      quit(0)
  if impostors.len == 0:
      echo "impostors lose."
      discard readLine(stdin)
      quit(0)
    
    