import asyncio
import time

async def asyncs():
    print('hello')
    await asyncio.sleep(1)
    print ('world')

async def say_after(delay, what):
    await asyncio.sleep(delay)
    print(what)

async def tasks():
    async with asyncio.TaskGroup() as tg:
        task1 = tg.create_task(
            say_after(1, 'hello')
        )

        task2 = tg.create_task(
            say_after(2, 'world')
        )

        print(f"started at {time.strftime('%X')}")
    
    print(f"finished at {time.strftime('%X')}")

async def timeouts():
    try:
        async with asyncio.timeout(3):
            await(say_after(20, "hello"))
    except TimeoutError:
        print("The function timed out")

class Duck():
    def __init__(self, name):
        self.name = name
    
    async def quack(self):
        print(self.name + " quacks")

    async def quackAt(self, duck):
        other_name = duck.name
        print(self.name + " quacks at " + other_name)

    async def rename(self, new_name):
        print (self.name + " is now " + new_name)
        self.name = new_name

async def actors():
    alice = Duck("Alice")
    bob = Duck("Bob")

    task1 = asyncio.create_task(alice.quack())
    task2 = asyncio.create_task(bob.quack())
    task3 = asyncio.create_task(alice.quackAt(bob))
    task4 = asyncio.create_task(bob.quackAt(alice))
    task5 = asyncio.create_task(alice.rename("Alice 2"))
    task6 = asyncio.create_task(bob.rename("Bob 2"))

    await asyncio.gather(
        task1,
        task2,
        task3,
        task4,
        task5,
        task6
    )


asyncio.run(actors())