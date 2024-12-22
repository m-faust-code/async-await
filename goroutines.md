# goroutines and channels in go

## goroutines and async
Goroutines are lightweight threads that allow for code to be run asynchronously.

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

func main() {
	go say("world")		// prints hello world 5x in a random order
	say("hello")		// based on scheduler
}
```

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

go was designed at google for concurrency on servers and for use in large projects with complex APIs. It was also designed to be a simpler alternative to C++. When designing APIs, it can be helpful for the language to have less function coloring, because this limits the ways that users can use the abstraction. Of course, this is a tradeoff, because as we saw with the deadlock example, if channels are involved, it's likely that we will need to use goroutines.
