import UIKit
var fruits: [String] = ["Apple", "Banana", "Cherry", "Dragonfruit", "Peach"]
print(fruits[2]) 

var favoriteNumbers: Set<Int> = [5, 7, 9, 17, 21, 42] 
favoriteNumbers.insert(13)
print(favoriteNumbers)

var dict: [String: Int] = ["C++": 1979, "Java": 1995, "Swift": 2014]
print(dict["Swift"]!)

var colors: [String] = ["Red", "Yellow", "Blue", "Purple"]
colors[1] = "Green"
print(colors)


let setA: Set<Int> = [1, 2, 3, 4]
let setB: Set<Int> = [3, 4, 5, 6]
print(setA.intersection(setB))

var studentScores: [String: Int] = ["Akerke": 95, "Malika": 90, "Zhaniya": 98]
studentScores.updateValue(100, forKey: "Malika")
print(studentScores)

let firstFruits = ["apple", "banana"]
let secondFruits = ["cherry", "kiwi"]
print(firstFruits + secondFruits)


var countryPopulations: [String: Int] = ["USA": 349035494, "UK": 70045531]
countryPopulations["Kazakhstan"] = 21143208
print(countryPopulations)

let animalsOne: Set<String> = ["cat", "dog"]
let animalsTwo: Set<String> = ["dog", "horse"]
let finalSet = animalsOne.union(animalsTwo).subtracting(animalsTwo)
print(finalSet)

let studentGrades: [String: [Int]] = [
    "Me": [80, 90, 70],
    "notMe": [77, 85, 95]
]
print(studentGrades["Me"]![1])
