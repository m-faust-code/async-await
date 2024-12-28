> _Paul commentary:_
>
> Below are investigations of how Python, Swift, and Go handle functions that _execute concurrently_ (i.e. multiple function calls can overlap in time) without allowing the kind of unchecked parallelism of languages like C and Java that causes data races. A _data race_ occurs when separate threads read and write data in the same stretch of memory at the same time, potentially stepping on each other’s toes and causing data corruption.
>
> Languages like Java and C provide threads as their basic building block of concurrent code — a fully parallel “lots of code can run at once!” model — and then ask programmers to carefully keep track of which pieces of code might use the same data and protect that data with _locks_. A lock is a way of saying, “here is a point where one thread has to wait for another.” This approach is highly flexible, but it asks a lot of the programmer. It is brittle and error-prone.
>
> Python, Swift, and Go all offer alternatives that do _not_ use threads as the basic building block. Instead, they use various forms of [coroutines](https://en.wikipedia.org/wiki/Coroutine): functions that can pause, wait for something else to provide data, then resume at an arbitrary later time ([further reading](https://www.cs.tufts.edu/~nr/cs257/archive/roberto-ierusalimschy/revisiting-coroutines.pdf)). In this model, programmers don’t have to think about threads and locks; instead, they have to think about where code can suspend, and where data is sent from one concurrent function to another. It is an old idea dating back to the 1960s that have experienced renewed interest in the past decade or so.
>
> That is the context for the student investigations below.


# async/await in python and swift

- [**Python example code**](python-async-await.py)
- [**Swift  example code**](swift-async-await/Sources/main.swift)

## at a glance

| python | swift |
| ------ | ----- |
| asyncio package | standard library |
| declared `async def f()` | declared `func f() async` |
| invoked `asyncio.run(f())` | invoked `await f()` |

## tour of functions in example code

### asyncs
This function demonstrates basic async/await functionality. Notice that sleep throws as error in Swift but not in Python. For some reason the sleep function in Swift waits for a significantly longer time in Swift than I inputted, at least on my computer. _(Paul: I do not see this difference on my machine. /shrug)_

### say_after
Helper function. Prints a string after a set time

### tasks
This function creates two tasks which start running at the same time. In Python, to make tasks start at the same time, you can make a TaskGroup or you can use the gather() function. In Swift you can use withTaskGroupto make a task group, or you can await a list to start multiple tasks at the same time.

### timeouts
In python you can run a task with timeout which would cause the task to exit with a TimeoutError if it hasn't finished by the specified time. An equivalent does not exist in Swift, at least not in the standard library. 

### actors
In Swift actors are types like classes and structs. They are reference types like classes. Actors are like classes that are safer to use with concurrently running code. Unlike classes, only one task is allowed to access an actor's mutable state. When a task other than the one the actor is in tries to reference its mutable state, it has to call it using await. If the actors is busy in the middle of resolving a method or returning a variable to another task, it has to wait. This prevents data races and other problems caused by multiple tasks trying access the same object.

> _Paul aside_: What “busy” means here “any method of the actor is running but not awaiting.” When an actor method starts running, all other method calls queue up to wait their turn. As soon as that method hits an `await`, however, other method calls can jump in and have a turn; now is the the awaiting method that has to wait its turn.

In Swift I created a Duck actor to demonstrate. If you run the function you can see that the tasks can run in any order without causing problems. Python doesn't have actors, but I recreated the function using a class. The class doesn't have the same concurrency safety features that actors do, but the program is simple enough that it still runs without error. The python code always runs the tasks in the same order, so it is possible it is not actually running the tasks asynchronously. 

# goroutines and channels in go

## goroutines and async

Goroutines are lightweight threads that allow for code to be run asynchronously.

> _Paul aside_: If you think this just sounds like a corny pun on “coroutine,” you are correct!

To make a goroutine, you can use the go keyword before calling the function.

```
package main

import (
	"fmt"
	"time"
)

func say(s string) {
	for i := 0; i < 5; i++ {
		time.Sleep(100 * time.Millisecond)
		fmt.Println(s)
	}
}

func main() {                   // prints hello world 5 times
	go say("world")		// theoretically both the main thread and the goroutine wake up at about the same time
	say("hello")		// so the scheduler randomly results in either "hello\nworld\n" or "world\nhello\n"
}
```

(All examples taken from [a tour of go](https://go.dev/tour/concurrency/1). You can run and edit the code there if you'd like to see the output)

Notice how the same exact function is called with and without the go keyword.

With async await, you need to explicitly define a function as async in order to await its result. And only asynchronous functions can call other asynchronous functions.

This behavior is called function coloring, because if, for some reason, we pretend that async is a color, async functions color any function which calls them async.

## channels and await

We can communicate between threads by sending data through channels.

```
package main

import "fmt"

func sum(s []int, c chan int) {
	sum := 0
	for _, v := range s {
		sum += v
	}
	c <- sum 			// send sum to c
}

func main() {
	s := []int{7, 2, 8, -9, 4, 0}

	c := make(chan int)		// makes a channel for ints
	go sum(s[:len(s)/2], c)		// go sums half the list and sends result to c
	go sum(s[len(s)/2:], c)		// go sums the other half and sends result to c
	x, y := <-c, <-c 		// receives the first result from the channel into x, then the second result into y

	fmt.Println(x, y, x+y)
}
```

Channels block until both sides are ready. Depending on how long each part takes, code like this could run differently. If the first goroutine completes before the second and before we reach the line `x, y := <-c, <-c`, then that goroutine will block until the main function reaches that line. If the second goroutine completes before the first, then the result from the second function will end up being stored in x, and not y. And if the main function reaches the line before the goroutines send their data, then it will wait until something is sent into the channel.

This means that it is possible to deadlock with channels. Using channels outside of goroutines immediately causes deadlock. We can see that by removing the go keywords from the above example, or, even more simply:

```
c := make(chan int)
x := <-c		// causes deadlock because we block right here and now all goroutines are asleep
c <- 1			// never get to this line
```

This is sort of like if we were allowed to use the await keyword outside of an asynchronous function. In that case, our only synchronous thread would block until the await statement resolves, and it won't resolve because it's the only thread.

However, we are not allowed to do this, because languages with async/await color their functions, so we already know at compile time if it's possible for an await statement to resolve.

## language design philosophy

go was designed at google for concurrency on servers and for use in large projects with complex APIs. It was also designed to be a simpler alternative to C++. When designing APIs, it can be helpful for the language to have less function coloring, because this limits the ways that users can use the abstraction. Of course, this is a tradeoff, because as we saw with the deadlock example, if channels are involved, it's likely that we will need to use goroutines, so this can be seen as implicit function coloring. Speaking very generally, I think go prefers an implicit design in the pursuit of simplicity and giving users more freedom.
