import importlib
mod = importlib.import_module('app.database')
print('Base type:', type(getattr(mod,'Base',None)))
print('Engine:', getattr(mod,'engine',None))
print('AsyncSessionLocal:', getattr(mod,'AsyncSessionLocal',None))
