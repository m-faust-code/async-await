


func asyncs() async {
    print("hello")
    do {
        try await Task.sleep(for: .seconds(1))
    } catch {
        print("error")
    }
    print("world") 
}

func say_after(delay: Double, what: String) async-> Void{
    do {
        try await Task.sleep(for: .seconds(delay))
    } catch {
        print("error")
    }
    print(what)
}

func tasks() async {
    let clock = ContinuousClock()
    async let task1: Void = say_after(delay: 1, what: "hello")
    async let task2: Void = say_after(delay: 2, what: "world")
    let start_time = clock.now
    let _ = await [task1, task2]
    let end_time = clock.now
    let total_time = start_time.duration(to: end_time)
    print("total time:" + String(reflecting:total_time))
}

await tasks()



