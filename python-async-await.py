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

asyncio.run(tasks())