


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

actor Duck {
    var name: String

    init(name: String) {
        self.name = name
    }

    func quack() {
        print(name + " quacks")
    }

    func quackAt(duck: Duck) async {
        let other_name = await duck.name
        print(name + " quacks at " + other_name)
    }

    func rename(to new_name: String) {
        self.name = new_name
    }
}

func actors() async {
    let alice = Duck(name: "Alice")
    let bob = Duck(name: "Bob")


    async let task1: Void = alice.quack()
    async let task2: Void = bob.quack()
    async let task3: Void = alice.quackAt(duck: bob)
    async let task4: Void = bob.quackAt(duck: alice)
    async let task5: Void = alice.rename(to: "Alice 2")
    async let task6: Void = bob.rename(to: "Bob 2")

    await _ = [task1, task2, task3, task4, task5, task6]
}


await actors()



