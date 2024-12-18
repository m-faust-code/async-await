import asyncio

async def asyncs():
    print('hello')
    await asyncio.sleep(1)
    print ('world')

