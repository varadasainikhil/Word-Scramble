//
//  ContentView.swift
//  Word Scramble
//
//  Created by Sai Nikhil Varada on 6/11/24.
//

import SwiftUI

struct ContentView :View {
    @State private var wordsArray = [String]()
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var score = 0
    
    var body: some View {
        NavigationStack(){
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section{
                    ForEach(usedWords, id: \.self){word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .onSubmit(addNewWord)
            .alert(alertTitle, isPresented: $showingAlert){
                Button("OK"){}
            }message: {
                Text(alertMessage)
            }
            
            Text("Score : \(score)")
            .navigationTitle(rootWord)
            .toolbar{
                Button("End Game", action: endGame)
                Button("Next Word", action: chooseRandomWord)
            }
            .onAppear(perform:
                startGame)
        }
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try?String(contentsOf: startWordsURL){
                wordsArray = startWords.components(separatedBy: "\n")
                chooseRandomWord()
            }
        }
        else{
            fatalError("Could not load start.txt from the bundle.")
        }
    }
    
    func chooseRandomWord(){
        rootWord = wordsArray.randomElement() ?? "silkworm"
        let index = wordsArray.firstIndex(of: rootWord) ?? 0
        wordsArray.remove(at: index)
        withAnimation{
            usedWords.removeAll()
        }
    }
    
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        guard isOriginal(word: answer) else{
            wordError(title: "Stop Hallucinating.", message: "You have already found \(answer).")
            return
        }
        
        guard isRealWord(word: answer) else{
            wordError(title: "Are you high?", message: "\(answer) is not a real word.")
            return
        }
        
        guard isPossible(word: answer) else{
            wordError(title: "Please wear your prescriptive lens.", message: "You can only use the same number of letters in the root word. ")
            return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        score += answer.count
    }
    
    func isOriginal(word : String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word : String) -> Bool{
        var tempWord = rootWord
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }
            else{
                return false
            }
        }
        return true
    }
        
    func isRealWord(word : String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title : String, message : String){
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    
    func endGame(){
        alertTitle = "Game Ended."
        alertMessage = "Your score is \(score)"
        showingAlert = true
        
        score = 0
        
        withAnimation{
            usedWords.removeAll()
        }
    }
}
#Preview {
    ContentView()
}
