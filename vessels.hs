import Data.List
import System.IO
import Text.Read

--Vessel data structure - basically a tuple of Int (volume and contents)
data Vessel = Vessel Int Int deriving (Show, Eq, Read)

--State data structure - contains an arbitrary number of vessels (depends on the input)
type State = [Vessel]

--Path data structure - represents a sequence of states
type Path = [State]

--used to extract newly found states
takePathHeads :: [[State]] -> [State]
takePathHeads paths = map head paths

--says if a path reached given goal state
solutionFound :: Path -> State -> Bool
solutionFound (x : rest) solution
  | x == solution = True
  | otherwise = False

--generates possible extensions to a path
generateNewPaths :: Path -> [State] -> [[State]]
generateNewPaths path visited = map addStateToPath newStates
  where
    addStateToPath state = [state] ++ path
    newStates = findNewStates (head path) visited

--says if state contains any vessels - basically indicates if a state is valid
notEmpty :: State -> Bool
notEmpty state
  | (length state) > 0 = True
  | otherwise = False

--finds possible transfers from a state (new transfer also can't be already visited)
findNewStates :: State -> [State] -> [State]
findNewStates state visited = filter mapVisited newStates
  where
    mapTransfer = transfer state --is this correct?
    mapVisited = isNotInVisited visited
    newStates = filter notEmpty (map mapTransfer (generateAllMoves (length state)))

--helper function generating tuple of ints representing transfers as vessel indices
generateAllMoves :: Int -> [(Int, Int)]
generateAllMoves vesselCount = filter notSame [(x, y) | x <- [0 .. vesselCount - 1], y <- [0 .. vesselCount - 1]]
  where
    notSame (x, y) = x /= y

--says if state is in set of visited states
isNotInVisited :: [State] -> State -> Bool
isNotInVisited visited state = not (elem state visited)

--tests if given move causes overflow and if so, the move is not possible
isMovePossible :: (Int, Int) -> State -> Bool
isMovePossible (from, to) state = not (isOverflown fromEl toEl)
  where
    fromEl = state !! from
    toEl = state !! to
    isOverflown (Vessel fromVol fromCont) (Vessel toVol toCont) = ((fromCont + toCont) > toVol)

--outputs vessels after the transfer as a tuple (from, to)
transferVessels :: Vessel -> Vessel -> (Vessel, Vessel)
transferVessels (Vessel fromVolume fromContents) (Vessel toVolume toContents) = (newFromVessel, newToVessel)
  where
    newFromVessel = (Vessel fromVolume 0)
    newToVessel = (Vessel toVolume (fromContents + toContents))

--replaces a vessel (at given index) in a state with a new vessel
replaceNth :: Int -> Vessel -> State -> State
replaceNth _ _ [] = []
replaceNth n newVal (x : xs)
  | n == 0 = newVal : xs
  | otherwise = x : replaceNth (n -1) newVal xs

--outputs a new state after given transfer
transfer :: State -> (Int, Int) -> State
transfer state (from, to)
  | isMovePossible (from, to) state = replaceNth to (takeTo transferredVessels) (replaceNth from (takeFrom transferredVessels) state)
  | otherwise = [] --Invalid State
  where
    oldFromVessel = state !! from
    oldToVessel = state !! to
    transferredVessels = transferVessels oldFromVessel oldToVessel
    takeFrom (from, _) = from
    takeTo (_, to) = to

--bfs algorithm where nodes are a representation of vessels (their fillings) and edges represent transfers betweem them.
--nodes actually contain the whole sequence with the most recent state at the top (makes it easier "find" the solution)
bfs :: [[State]] -> State -> [State] -> [State]
bfs [] solution visited = [] --nosolution
bfs (x : queueRest) solution visited
  | solutionFound x solution = reverse x
  | otherwise = bfs newQueue solution newVisited
  where
    newPaths = (generateNewPaths x visited)
    newQueue = queueRest ++ newPaths
    newVisited = visited ++ (takePathHeads newPaths)

--wrapper around bfs function
findSolution :: State -> State -> Path
findSolution start goal = bfs [[start]] goal []

--checks if input states (initial and final) are valid
checkIfVesselsCorrect :: State -> Bool
checkIfVesselsCorrect [] = True
checkIfVesselsCorrect (x : rest) =
  if vesselCorrect x
    then do checkIfVesselsCorrect rest
    else False
  where
    vesselCorrect (Vessel volume content) = volume >= content

--checks if given input has a lenght divisible by 3
checkIfInputLenghtCorrect :: [String] -> Bool
checkIfInputLenghtCorrect words
  | ((mod (inputLength) 3) == 0) && inputLength >= 3 = True
  | otherwise = False
  where
    inputLength = length words

--checks if given input only consists of numbers
checkIfInputFormatCorrect :: [String] -> Bool
checkIfInputFormatCorrect [] = True
checkIfInputFormatCorrect (x : rest) =
  if (readMaybe x :: Maybe Int) == Nothing
    then False
    else checkIfInputFormatCorrect rest

--parses list of strings into state data structures
parseInputInner :: [String] -> State -> State -> (State, State)
parseInputInner [] init goal = (init, goal)
parseInputInner (a : b : c : rest) init goal = parseInputInner rest newInit newGoal
  where
    volume = read a :: Int
    initCon = read b :: Int
    goalCon = read c :: Int
    newInit = init ++ [Vessel volume initCon]
    newGoal = goal ++ [Vessel volume goalCon]

--wrapper around parseInputInner
parseInput :: [String] -> (State, State)
parseInput words = parseInputInner words [] []

--OUTPUT PRINT FUNCTIONS - begin
printVessel :: Vessel -> Int -> IO ()
printVessel (Vessel volume content) id = do
  putStr (show id)
  putStr "-(volume:"
  putStr (show volume)
  putStr ",content:"
  putStr (show content)
  putStr ")"

printStateInner :: State -> Int -> IO ()
printStateInner [] _ = return ()
printStateInner (x : rest) id = do
  printVessel x id
  putStr " "
  printStateInner rest (id + 1)

printState :: State -> IO ()
printState state = printStateInner state 1

printResultInner :: [State] -> Int -> IO ()
printResultInner [] _ = return ()
printResultInner (x : rest) 1 = do
  putStrLn "SOLUTION:"
  putStr "1.step : "
  printState x
  putStrLn ""
  printResultInner rest 2
printResultInner (x : rest) order = do
  putStr (show order)
  putStr ".step : "
  printState x
  putStrLn ""
  printResultInner rest (order + 1)

printResult :: [State] -> IO ()
printResult [] =
  putStrLn "No solution found"
printResult result =
  printResultInner result 1

--OUTPUT PRINT FUNCTIONS - end

--Main function
main :: IO ()
main = do
  splitted <- getContents >>= return . words
  let states = parseInput splitted
  let inputCorrect = checkInputs splitted
  let statesCorrect = (checkIfVesselsCorrect (fst states)) && (checkIfVesselsCorrect (snd states))
  let result = findSolution (fst states) (snd states)
  if not inputCorrect
    then putStrLn "Invalid input"
    else do
      if not statesCorrect
        then putStrLn "Invalid vessel (volume < content)"
        else do printResult result
  where
    checkInputs input = checkIfInputLenghtCorrect input && checkIfInputFormatCorrect input