# Practicals project [NPRG005] - Vessels

## Problem description

- There are N vessels, their volume, initial filling and final filling. Create a program that finds the shortest sequence from the initial state to the final state.
- Transfers from one vessel to another are allowed under following conditions
  - vessel that it is poured from has to be completely emptied
  - overflows are allowed though

## My solution

I used BFS algorithm, where nodes are a representation of a given set of vessels (their fillings) and edges represent transfers between them. Program ends succesfully when BFS algorithm reaches the final filling, otherwise fails when the queue is empty.

For more information check out comments in the code.

## Usage

Program takes input from console in the following format:

- each vessel is represented by a triplet of numbers divided by a sequence of whitespaces (these triplets are also divided by whitespaces - it is recommended to use spaces inside the triplets and newlines between them for better readability of the input)
- first number represents vessel's volume, second one its initial filling and the third one its final filling
  f.e.:

```
1 1 0
2 1 0
3 1 0
4 1 4
```

given input represents 3 vessels: first (volume: 1, initial filling: 1, final filling: 0), second (volume: 1, initial filling: 1, final filling: 0) and third (volume: 2, initial filling: 0, final filling: 1)

- solution will be printed as a sequence of vessel fillings (state), each on a single line (if valid solution exists, otherwise the program will print "No solution exists")
- each vessel filling will consist of vessels (in parenthesis) printed in the order it was given by a user (also specified as a number in front of every vessel)
  f.e.:

```
1.step : 1-(volume:1,content:1) 2-(volume:2,content:1) 3-(volume:3,content:1) 4-(volume:4,content:1)
2.step : 1-(volume:1,content:0) 2-(volume:2,content:2) 3-(volume:3,content:1) 4-(volume:4,content:1)
3.step : 1-(volume:1,content:0) 2-(volume:2,content:0) 3-(volume:3,content:3) 4-(volume:4,content:1)
4.step : 1-(volume:1,content:0) 2-(volume:2,content:0) 3-(volume:3,content:0) 4-(volume:4,content:4)
```

## Build

Run the following command :

```
ghc -o "output executable name" "path to vessels.hs"
```

## Props
Thank you!
