Async/Await in Python and Swift:

Basic differences:
    - In Python async/await is part of the asyncio package. In Swift it is part of the standard library
    - In Python an asynchronus function is declared with "async def function_name()." In Swift it is declared by "func function_name async."
    - In Python you run an asynchronus function with "asyncio.run(function_name())." In Swift you run an asynchronus function with "await function_name()"

asyncs function: This function demonstrates basic async/await functionality. Notice that sleep throws as error in Swift but not in Python. For some reason the sleep function in Swift waits for a significantly longer time in Swift than I inputted, at least on my computer.

say_after: helper function. Prints a string after a set time

tasks function: This function creates two tasks which start running at the same time. In Python, to make tasks start at the same time, you can make a TaskGroup or you can use the gather() function. In Swift you can use withTaskGroupto make a task group, or you can await a list to start multiple tasks at the same time.

timeouts function: In python you can run a task with timeout which would cause the task to exit with a TimeoutError if it hasn't finished by the specified time. An equivalent does nogt exist in Swift, at least not in the standard library. 

actors: In Swift actors are types like classes and structs. They are reference types like classes. Actors are like classes that are safer to use with concurrently running code. Unlike classes, only one task is allowed to acces an actor's mutable state. When a task other than the one the actor is in tries to reference its mutable state, it has to call it using await. If the actors is busy in the middle of resolving a method or returning a variable to another task, it has to wait. This prevents data races and other problems caused by multiple tasks trying access the same object. In Swift I created a Duck actor to demonstrate. If you run the function you can see that the tasks can run in any order without causing problems. Python doesn't have actors, but I recreated the function using a class. The class doesn't have the same concurrency safety features that actors do, but the program is simple enough that it still runs without error. The python code always runs thae tasks in the same order, so it is possible it is not actually running the tasks asynchronously. 
