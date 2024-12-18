
func asyncs() async {
    print("hello")
    do {
        try await Task.sleep(nanoseconds:1000000000)
    } catch {
        print("error")
    }
    print("world") 
}


await asyncs()



